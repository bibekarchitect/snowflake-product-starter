# Snowflake Data Product — GitHub Actions Starter (Single Manifest)

This repository provides an automated, **end-to-end pipeline** to define and deploy Snowflake-based data products using a single manifest file (`product.yml`), **Terraform**, and **GitHub Actions**.

It creates and manages:
- Warehouses and resource monitors (via Terraform)
- Database and schema layout
- Tables, streams, tasks, and dynamic tables
- Secure product views and Snowflake shares
- Optional DataHub catalog ingestion recipe

---

## 🧩 1. Prerequisites

### 1.1 Snowflake Account
You can use:
- A **Snowflake Enterprise free trial**, or  
- Any Enterprise/Business-Critical edition account.

> If you’re on a *Standard* trial, simply remove the `masking_policies` section from `product.yml` — it’s an Enterprise-only feature.

### 1.2 GitHub Account
You’ll need permission to:
- Create **private repositories**
- Configure **GitHub Environments** and **Secrets**
- Run **GitHub Actions**

### 1.3 Local Tools (optional)
Only needed if you test locally:
```bash
brew install terraform python3 git
pip install PyYAML jinja2 python-dotenv
```

---

## 🧱 2. Repository Overview

```
snowflake-manifest-github-actions-starter/
├── .github/workflows/publish.yml   # GitHub Actions workflow
├── terraform/                      # Warehouses, monitor, optional DB
├── tools/
│   ├── runner.py                   # Renders SQL from product.yml
│   └── requirements.txt
├── product.yml                     # Main manifest (data product spec)
├── datahub/recipe.template.yml     # Optional DataHub ingestion config
└── README.md                       # This guide
```

---

## 🧭 3. Step-by-Step Setup Guide

### Step 1 — Create the Snowflake CI User and Role
In the Snowflake UI (using `ACCOUNTADMIN`):

```sql
CREATE ROLE IF NOT EXISTS CICD_SNOWFLAKE_DEPLOY;
CREATE USER IF NOT EXISTS CICD_BOT
  PASSWORD = '<<SET_A_STRONG_TEMP_PASSWORD>>'
  DEFAULT_ROLE = CICD_SNOWFLAKE_DEPLOY
  MUST_CHANGE_PASSWORD = TRUE;
GRANT ROLE CICD_SNOWFLAKE_DEPLOY TO USER CICD_BOT;

CREATE ROLE IF NOT EXISTS CUSTOMER360_OWNER;
CREATE ROLE IF NOT EXISTS CUSTOMER360_WRITER;
CREATE ROLE IF NOT EXISTS CUSTOMER360_READER;
CREATE ROLE IF NOT EXISTS CUSTOMER360_PUBLISHER;

GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE CICD_SNOWFLAKE_DEPLOY;
GRANT MONITOR USAGE ON ACCOUNT TO ROLE CICD_SNOWFLAKE_DEPLOY;
CREATE DATABASE IF NOT EXISTS CUSTOMER360_DEV;
GRANT USAGE, CREATE SCHEMA ON DATABASE CUSTOMER360_DEV TO ROLE CICD_SNOWFLAKE_DEPLOY;
```

To allow database creation automatically:
```sql
GRANT CREATE DATABASE ON ACCOUNT TO ROLE CICD_SNOWFLAKE_DEPLOY;
```

To allow product sharing:
```sql
GRANT CREATE SHARE ON ACCOUNT TO ROLE CICD_SNOWFLAKE_DEPLOY;
```

---

### Step 2 — Push the Repository to GitHub

```bash
git init
git add .
git commit -m "init: snowflake data product starter"
git branch -M main
git remote add origin <YOUR_REPO_URL>
git push -u origin main
```

---

### Step 3 — Configure GitHub **Environments** and **Secrets**

Create three environments:
- `dev`
- `uat`
- `prod`

For each, add these **secrets**:

| Secret | Example | Required |
|:--|:--|:--:|
| SNOWFLAKE_ACCOUNT | `xy12345` | ✅ |
| SNOWFLAKE_USER | `CICD_BOT` | ✅ |
| SNOWFLAKE_PASSWORD | your password | ✅ |
| SNOWFLAKE_ROLE | `CICD_SNOWFLAKE_DEPLOY` | ✅ |
| SNOWFLAKE_REGION | `ap-south-1` | ✅ |
| DATAHUB_GMS_HOST | `https://datahub.myorg.com` | ⏳ |
| DATAHUB_GMS_TOKEN | `<token>` | ⏳ |

> ✅ Required ⏳ Optional (only for catalog generation)

---

## 🚀 4. Running the Pipeline

### 4.1 Dry-Run (Plan Only)
1. Go to **Actions → Publish Data Product (Fixed)**.  
2. Click **Run workflow**.  
3. Inputs:
   - environment: `dev`
   - apply: `false`
   - execute_sql: `false`
   - catalog: `false`
   - create_database: `false`

🟢 This generates a **Terraform Plan** and **renders SQL** without applying anything.

---

### 4.2 Apply Infrastructure (no SQL execution)
Run again with:
```
environment: dev
apply: true
execute_sql: false
catalog: false
create_database: false
```
Terraform creates warehouses and resource monitors. SQL is rendered as artifacts.

---

### 4.3 Execute SQL (Full Deployment)
Run again with:
```
environment: dev
apply: true
execute_sql: true
catalog: false
create_database: false
```

This step will:
- Create schemas, tables, streams, tasks
- Build CURATED and PRODUCT layers
- Publish secure views
- Optionally create a Snowflake Share

> ⚠️ If network policy blocks GitHub runners, keep `execute_sql=false`.  
> Then download the SQL artifact and run it manually in Snowflake.

---

### 4.4 Verify in Snowflake
```sql
USE DATABASE CUSTOMER360_DEV;
SHOW SCHEMAS;
SHOW TABLES IN SCHEMA RAW;
SHOW VIEWS  IN SCHEMA PRODUCT;
SHOW TASKS; SHOW STREAMS;
SHOW SHARES LIKE 'DP_CUSTOMER360_ORDERS_V1';
```

---

## 🧪 5. Evolving the Product

Edit `product.yml`:
- Add real columns in `ingest.columns`
- Update `merge_sql` under `transform.incremental`
- Add more models (dynamic tables or views)
- Define masking/tagging under `governance`
- Update `product_contract.views` for new versions (e.g., `ORDERS_V2`)
- Add new consumer accounts under `publishing.consumers`

Commit & push → re-run the workflow.

---

## 📦 6. Promotion Flow
- Run the pipeline in `dev` first.
- Modify `layout.database` and `governance.tags.ENV` to match `uat` / `prod`.
- Trigger the workflow for each environment separately.

---

## 🧰 7. Troubleshooting

| Issue | Fix |
|:--|:--|
| `Permission denied` in Terraform | Grant `CREATE WAREHOUSE`, `MONITOR USAGE`, and DB privileges to the CI role. |
| `Network error` during SQL exec | Keep `execute_sql=false`, download SQL, apply manually. |
| `Task suspended` | Resume it: `ALTER TASK ... RESUME;` |
| Dynamic table not refreshing | Check `TARGET_LAG` and ensure transform warehouse exists. |
| Share not visible | Verify correct consumer account locator. |

---

## 🔍 8. Trial Account Notes
✅ Works perfectly with **Enterprise free trial**.  
⚙️ On **Standard trial**, remove `masking_policies` (Enterprise-only).

Trial credits allow ~30 days of full functionality.

---

## 🧾 9. References
- [Snowflake Dynamic Tables](https://docs.snowflake.com/en/user-guide/dynamic-tables-intro)
- [Terraform Snowflake Provider](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest)
- [DataHub Snowflake Source](https://datahubproject.io/docs/generated/ingestion/sources/snowflake/)

---

## ✅ Summary

| Layer | Defined In | Deployed By | Description |
|:--|:--|:--|:--|
| Infra (Warehouses, Monitors) | `terraform/` | GitHub Actions | Provision compute and quotas |
| Data Model (Tables, Streams, Tasks) | `product.yml` → rendered SQL | `runner.py` | Create/transform data |
| Product Views | `product_contract` | SQL Execution | Published to consumers |
| Catalog Metadata | `datahub/recipe.template.yml` | Optional | DataHub ingestion |

---

### Author Notes
This starter is production-safe and fully compatible with Snowflake’s **Enterprise trial** edition.  
You can now focus on defining **data contracts** — the workflow handles the rest.