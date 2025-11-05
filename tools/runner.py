#!/usr/bin/env python3
import argparse, os, yaml, pathlib
from jinja2 import Template
from dotenv import load_dotenv
load_dotenv()

def load_manifest(path):
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def validate_manifest(m):
    for k in ["product","layout","compute"]:
        if k not in m: raise SystemExit(f"Manifest missing: {k}")
    if "database" not in m["layout"]: raise SystemExit("layout.database required")
    return True

def render_sql(m, out_dir, dry=False):
    db = m["layout"]["database"]
    raw = m["layout"]["schemas"]["raw"]
    curated = m["layout"]["schemas"]["curated"]
    product = m["layout"]["schemas"]["product"]
    meta = m["layout"]["schemas"]["meta"]

    out = pathlib.Path(out_dir); out.mkdir(parents=True, exist_ok=True)
    def write(name, sql):
        p = out / f"{name}.sql"; p.write_text(sql.strip()+"\n", encoding="utf-8"); print(f"[render] {p}")

    write("01_schemas", f"""
    CREATE SCHEMA IF NOT EXISTS {db}.{raw};
    CREATE SCHEMA IF NOT EXISTS {db}.{curated};
    CREATE SCHEMA IF NOT EXISTS {db}.{product};
    CREATE SCHEMA IF NOT EXISTS {db}.{meta};
    """)

    ingest = m.get("ingest", {})
    cols=[]; 
    for c in ingest.get("columns", []):
        d = f" DEFAULT {c['default']}" if "default" in c else ""
        cols.append(f"{c['name']} {c['type']}{d}")
    raw_table = ingest.get("raw_table", f"{raw}.RAW_SRC")
    write("02_raw_table", f"CREATE OR REPLACE TABLE {db}.{raw_table} ({', '.join(cols)});")

    incr = m.get("transform", {}).get("incremental", {})
    if incr.get("use_streams_tasks"):
        stream = incr["stream"]
        write("03_stream", f"CREATE OR REPLACE STREAM {db}.{stream} ON TABLE {db}.{raw_table};")
        merge = Template(incr["merge_sql"]).render(db=db, raw=raw, curated=curated, product=product, meta=meta)
        tname = "T_LOAD_"+raw_table.split(".")[-1]
        cron = incr.get("schedule_cron_utc","0 */1 * * *")
        write("04_task_merge", f"""
        CREATE OR REPLACE TASK {db}.{meta}.{tname}
          WAREHOUSE = {m["compute"]["warehouses"]["transform"]}
          SCHEDULE = 'USING CRON {cron} UTC'
          WHEN SYSTEM$STREAM_HAS_DATA('{db}.{stream}')
        AS
        {merge};
        ALTER TASK {db}.{meta}.{tname} RESUME;
        """)

    for model in m.get("models", []):
        q = Template(model["query"]).render(db=db, raw=raw, curated=curated, product=product, meta=meta)
        name = model["name"]; mtype = model.get("type","view").lower()
        if mtype=="dynamic_table":
            sql=f"""
            CREATE OR REPLACE DYNAMIC TABLE {db}.{name}
            TARGET_LAG = '5 minutes'
            WAREHOUSE = {model.get("target_warehouse", m["compute"]["warehouses"]["transform"])}
            AS {q};
            """
        elif mtype=="table":
            sql=f"CREATE OR REPLACE TABLE {db}.{name} AS {q};"
        else:
            sql=f"CREATE OR REPLACE VIEW {db}.{name} AS {q};"
        write(f"05_model_{name.replace('.','_')}", sql)

    for v in m.get("product_contract", {}).get("views", []):
        vt = "SECURE VIEW" if v.get("secure", True) else "VIEW"
        q = Template(v["sql"]).render(db=db, raw=raw, curated=curated, product=product, meta=meta)
        name = v["name"]
        write(f"06_product_{name.replace('.','_')}", f"CREATE OR REPLACE {vt} {db}.{name} AS {q};")

    tags = m.get("governance", {}).get("tags", {})
    if tags:
        pairs = ", ".join([f"{k} = '{v}'" for k,v in tags.items()])
        write("07_tags", f"ALTER TABLE {db}.{raw_table} SET TAG {pairs};")

    mp = m.get("governance", {}).get("masking_policies", {})
    for _, pol in mp.items():
        write("08_masking_policy", pol["policy_sql"])

    pub = m.get("publishing", {})
    if pub.get("method") == "share":
        share = pub["share_name"]
        lines=[
            f"CREATE OR REPLACE SHARE {share};",
            f"GRANT USAGE ON DATABASE {db} TO SHARE {share};",
            f"GRANT USAGE ON SCHEMA {db}.{product} TO SHARE {share};",
            f"GRANT SELECT ON ALL VIEWS IN SCHEMA {db}.{product} TO SHARE {share};"
        ]
        for c in pub.get("consumers", []):
            lines.append(f"ALTER SHARE {share} ADD ACCOUNT = {c['account']};")
        write("09_share", "\n".join(lines))

if __name__ == "__main__":
    import argparse
    ap=argparse.ArgumentParser()
    sub=ap.add_subparsers(dest="cmd", required=True)
    p=sub.add_parser("validate"); p.add_argument("--manifest", required=True)
    p=sub.add_parser("render");   p.add_argument("--manifest", required=True); p.add_argument("--out", required=True); p.add_argument("--dry-run", action="store_true")
    p=sub.add_parser("exec");     p.add_argument("--in", dest="indir", required=True)
    p=sub.add_parser("publish");  p.add_argument("--manifest", required=True)
    p=sub.add_parser("catalog");  p.add_argument("--manifest", required=True)
    p=sub.add_parser("rollback"); p.add_argument("--manifest", required=True)
    args=ap.parse_args()

    if args.cmd!="exec":
        m=load_manifest(getattr(args,"manifest")); validate_manifest(m)

    if args.cmd=="validate": print("OK: manifest validated.")
    elif args.cmd=="render": render_sql(m, args.out, dry=args.dry_run) or (print("[dry-run] SQL rendered only.") if args.dry_run else None)
    elif args.cmd=="exec": print("[exec] Provide your own SnowSQL execution if needed.")
    elif args.cmd=="publish": print("Publishing SQL is generated as 09_share.sql during render.")
    elif args.cmd=="catalog":
        import pathlib, os
        pathlib.Path("build").mkdir(parents=True, exist_ok=True)
        from yaml import safe_dump
        db=m["layout"]["database"]
        recipe={
          "source":{"type":"snowflake","config":{
            "account_id":os.getenv("SNOWFLAKE_ACCOUNT","YOUR_ACCT"),
            "username":os.getenv("SNOWFLAKE_USER","YOUR_USER"),
            "password":os.getenv("SNOWFLAKE_PASSWORD","YOUR_PASS"),
            "role":os.getenv("SNOWFLAKE_ROLE","CATALOG_RO"),
            "warehouse":os.getenv("SNOWFLAKE_WAREHOUSE","CATALOG_WH"),
            "include_lineage":True,
            "database_pattern":{"allow":[db]}
          }},
          "sink":{"type":"datahub-rest","config":{
            "server":os.getenv("DATAHUB_GMS_HOST","http://datahub-gms:8080"),
            "token":os.getenv("DATAHUB_GMS_TOKEN","YOUR_TOKEN")
          }}
        }
        pathlib.Path("build/datahub_snowflake_recipe.yml").write_text(safe_dump(recipe), encoding="utf-8")
        print("[catalog] Wrote build/datahub_snowflake_recipe.yml")
    elif args.cmd=="rollback":
        db=m["layout"]["database"]
        print(f"Rollback: use CLONE/Time Travel to restore objects in {db}.")
