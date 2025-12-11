import os
import yaml
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional

import snowflake.connector

from models import DataProductContract, DataProduct

# --- DataHub Libraries ---
from datahub.emitter.rest_emitter import DatahubRestEmitter
from datahub.emitter.mce_builder import (
    make_dataset_urn,
    make_data_platform_urn,
    make_user_urn,
    make_tag_urn,
)
from datahub.emitter.mcp import MetadataChangeProposalWrapper
from datahub.metadata.schema_classes import (
    DatasetPropertiesClass,
    SchemaMetadataClass,
    SchemaFieldClass,
    SchemaFieldDataTypeClass,
    StringTypeClass,
    NumberTypeClass,
    OwnerClass,
    OwnershipClass,
    OwnershipTypeClass,
    GlobalTagsClass,
    TagAssociationClass,
    DataProductPropertiesClass,
    UpstreamLineageClass,
    UpstreamClass,
)


app = FastAPI(title="Data Product Operator API")


class DataProductRequest(BaseModel):
    contract_yaml: str


# ---------- Config via environment vars ----------

SNOWFLAKE_USER = os.getenv("SNOWFLAKE_USER")
SNOWFLAKE_PASSWORD = os.getenv("SNOWFLAKE_PASSWORD")
SNOWFLAKE_ROLE = os.getenv("SNOWFLAKE_ROLE", "SYSADMIN")
DEFAULT_SNOWFLAKE_ACCOUNT = os.getenv("SNOWFLAKE_ACCOUNT")

DATAHUB_GMS_URL = os.getenv("DATAHUB_GMS_URL", "http://datahub-gms:8080")
DATAHUB_TOKEN = os.getenv("DATAHUB_TOKEN")

emitter = DatahubRestEmitter(
    gms_server=DATAHUB_GMS_URL,
    token=DATAHUB_TOKEN,
)


# ---------- Snowflake helpers ----------

def connect_snowflake(dp: DataProduct):
    account = dp.snowflake.account or DEFAULT_SNOWFLAKE_ACCOUNT
    if not (SNOWFLAKE_USER and SNOWFLAKE_PASSWORD and account):
        raise RuntimeError("Snowflake credentials or account not configured")

    return snowflake.connector.connect(
        user=SNOWFLAKE_USER,
        password=SNOWFLAKE_PASSWORD,
        account=account,
        role=SNOWFLAKE_ROLE,
        warehouse=dp.snowflake.warehouse,
    )


def create_or_update_snowflake(dp: DataProduct):
    conn = connect_snowflake(dp)
    cur = conn.cursor()
    db = dp.snowflake.database
    schema = dp.snowflake.schema
    table = dp.snowflake.table

    try:
        cur.execute(f"CREATE DATABASE IF NOT EXISTS {db}")
        cur.execute(f"CREATE SCHEMA IF NOT EXISTS {db}.{schema}")

        cols = [f"{c.name} {c.type}" for c in dp.schema]
        col_ddl = ", ".join(cols)

        cur.execute(f"""
            CREATE TABLE IF NOT EXISTS {db}.{schema}.{table} ({col_ddl})
        """)

        if dp.snowflake.cluster_by:
            cluster_cols = ", ".join(dp.snowflake.cluster_by)
            cur.execute(
                f"ALTER TABLE {db}.{schema}.{table} CLUSTER BY ({cluster_cols})"
            )

    finally:
        cur.close()
        conn.close()


# ---------- DataHub registration helpers ----------

def register_dataset_and_metadata(dp: DataProduct) -> str:
    dataset_name = f"{dp.snowflake.database}.{dp.snowflake.schema}.{dp.snowflake.table}"
    dataset_urn = make_dataset_urn("snowflake", dataset_name, "PROD")

    # dataset properties
    props = DatasetPropertiesClass(description=dp.description)
    emitter.emit(MetadataChangeProposalWrapper(entityUrn=dataset_urn, aspect=props))

    # ownership
    owner = OwnershipClass(
        owners=[OwnerClass(owner=make_user_urn(dp.owner), type=OwnershipTypeClass.DATAOWNER)]
    )
    emitter.emit(MetadataChangeProposalWrapper(entityUrn=dataset_urn, aspect=owner))

    # tags
    if dp.tags:
        tags = GlobalTagsClass(
            tags=[TagAssociationClass(tag=make_tag_urn(t)) for t in dp.tags]
        )
        emitter.emit(MetadataChangeProposalWrapper(entityUrn=dataset_urn, aspect=tags))

    # schema
    fields = []
    for col in dp.schema:
        if col.type.upper().startswith("NUMBER"):
            dtype = NumberTypeClass()
        else:
            dtype = StringTypeClass()

        fields.append(
            SchemaFieldClass(
                fieldPath=col.name,
                type=SchemaFieldDataTypeClass(type=dtype),
                nativeDataType=col.type,
                description=col.description or "",
            )
        )

    schema = SchemaMetadataClass(
        schemaName=dataset_name,
        platform=make_data_platform_urn("snowflake"),
        version=0,
        fields=fields,
    )
    emitter.emit(MetadataChangeProposalWrapper(entityUrn=dataset_urn, aspect=schema))

    # upstream lineage
    if dp.upstream_sources:
        upstreams = []
        for src in dp.upstream_sources:
            platform = src.type.lower()
            upstream_urn = make_dataset_urn(platform, src.name, "PROD")
            upstreams.append(UpstreamClass(dataset=upstream_urn, type="TRANSFORMED"))

        lineage = UpstreamLineageClass(upstreams=upstreams)
        emitter.emit(MetadataChangeProposalWrapper(entityUrn=dataset_urn, aspect=lineage))

    return dataset_urn


def register_dataproduct(dp: DataProduct, dataset_urn: str) -> str:
    data_product_urn = f"urn:li:dataProduct:{dp.domain}.{dp.name}"

    props = DataProductPropertiesClass(
        name=dp.display_name,
        description=dp.description,
        domain=f"urn:li:domain:{dp.domain}",
        entities=[dataset_urn],
    )

    emitter.emit(
        MetadataChangeProposalWrapper(entityUrn=data_product_urn, aspect=props)
    )

    return data_product_urn


# ---------- API endpoint ----------

@app.post("/data-products")
def create_data_product(req: DataProductRequest):
    try:
        raw_yaml = yaml.safe_load(req.contract_yaml)
        contract = DataProductContract.parse_obj(raw_yaml)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid YAML contract: {e}")

    dp = contract.data_product

    try:
        create_or_update_snowflake(dp)
        dataset_urn = register_dataset_and_metadata(dp)
        dp_urn = register_dataproduct(dp, dataset_urn)

        return {
            "status": "success",
            "dataset_urn": dataset_urn,
            "data_product_urn": dp_urn,
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Processing error: {e}")