import os
import yaml

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional

import snowflake.connector

from models import DataProductContract, DataProduct

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


# ---------- FastAPI setup ----------

app = FastAPI(title="Data Product Operator API")


class DataProductRequest(BaseModel):
    contract_yaml: str


# ---------- Config via environment ----------

SNOWFLAKE_USER = os.getenv("SNOWFLAKE_USER")
SNOWFLAKE_PASSWORD = os.getenv("SNOWFLAKE_PASSWORD")
SNOWFLAKE_ROLE = os.getenv("SNOWFLAKE_ROLE", "SYSADMIN")

# Snowflake account can also come from contract.snowflake.account
DEFAULT_SNOWFLAKE_ACCOUNT = os.getenv("SNOWFLAKE_ACCOUNT")

DATAHUB_GMS_URL = os.getenv("DATAHUB_GMS_URL", "http://datahub-gms:8080")
DATAHUB_TOKEN = os.getenv("DATAHUB_TOKEN")  # optional

emitter = DatahubRestEmitter(
    gms_server=DATAHUB_GMS_URL,
    token=DATAHUB_TOKEN,
)


# ---------- Helpers ----------

def connect_snowflake(dp: DataProduct):
    account = dp.snowflake.account or DEFAULT_SNOWFLAKE_ACCOUNT
    if not (SNOWFLAKE_USER and SNOWFLAKE_PASSWORD and account):
        raise RuntimeError("Snowflake credentials or account not configured")

    conn = snowflake.connector.connect(
        user=SNOWFLAKE_USER,
        password=SNOWFLAKE_PASSWORD,
        account=account,
        role=SNOWFLAKE_ROLE,
        warehouse=dp.snowflake.warehouse,
    )
    return conn


def create_or_update_snowflake_assets(dp: DataProduct):
    db = dp.snowflake.database
    schema = dp.snowflake.schema
    table = dp.snowflake.table

    conn = connect_snowflake(dp)
    cur = conn.cursor()
    try:
        cur.execute(f"CREATE DATABASE IF NOT EXISTS {db}")
        cur.execute(f"CREATE SCHEMA IF NOT EXISTS {db}.{schema}")

        # Build column DDL from contract schema
        cols = []
        for col in dp.schema:
            name = col.name
            dtype = col.type
            cols.append(f"{name} {dtype}")
        col_ddl = ", ".join(cols)

        # Simple create-if-not-exists; you can extend to ALTER for updates
        cur.execute(
            f"CREATE TABLE IF NOT EXISTS {db}.{schema}.{table} ({col_ddl})"
        )

        # Optionally handle clustering keys
        if dp.snowflake.cluster_by:
            cluster_cols = ", ".join(dp.snowflake.cluster_by)
            cur.execute(
                f"ALTER TABLE {db}.{schema}.{table} "
                f"CLUSTER BY ({cluster_cols})"
            )

    finally:
        cur.close()
        conn.close()


def register_dataset_and_metadata(dp: DataProduct) -> str:
    dataset_name = f"{dp.snowflake.database}.{dp.snowflake.schema}.{dp.snowflake.table}"
    dataset_urn = make_dataset_urn(
        platform="snowflake",
        name=dataset_name,
        env="PROD",
    )

    # Dataset properties (description, tags)
    props = DatasetPropertiesClass(
        description=dp.description,
    )
    emitter.emit(
        MetadataChangeProposalWrapper(
            entityUrn=dataset_urn,
            aspect=props,
        )
    )

    # Ownership
    ownership = OwnershipClass(
        owners=[
            OwnerClass(
                owner=make_user_urn(dp.owner),
                type=OwnershipTypeClass.DATAOWNER,
            )
        ]
    )
    emitter.emit(
        MetadataChangeProposalWrapper(
            entityUrn=dataset_urn,
            aspect=ownership,
        )
    )

    # Global tags
    if dp.tags:
        tag_assocs = [
            TagAssociationClass(tag=make_tag_urn(tag)) for tag in dp.tags
        ]
        global_tags = GlobalTagsClass(tags=tag_assocs)
        emitter.emit(
            MetadataChangeProposalWrapper(
                entityUrn=dataset_urn,
                aspect=global_tags,
            )
        )

    # Schema
    fields = []
    for col in dp.schema:
        logical = col.type.upper()
        if logical.startswith("NUMBER"):
            dtype = NumberTypeClass()
        else:
            dtype = StringTypeClass()

        fields.append(
            SchemaFieldClass(
                fieldPath=col.name,
                type=SchemaFieldDataTypeClass(type=dtype),
                nativeDataType=logical,
                description=col.description or "",
            )
        )

    schema = SchemaMetadataClass(
        schemaName=dataset_name,
        platform=make_data_platform_urn("snowflake"),
        version=0,
        fields=fields,
    )
    emitter.emit(
        MetadataChangeProposalWrapper(
            entityUrn=dataset_urn,
            aspect=schema,
        )
    )

    # Upstream lineage (optional)
    if dp.upstream_sources:
        upstreams = []
        for src in dp.upstream_sources:
            if src.type.lower() == "snowflake":
                upstream_urn = make_dataset_urn(
                    platform="snowflake",
                    name=src.name,
                    env="PROD",
                )
            elif src.type.lower() == "kafka":
                # simplistic; adjust to your Kafka naming convention
                upstream_urn = make_dataset_urn(
                    platform="kafka",
                    name=src.name,
                    env="PROD",
                )
            else:
                continue

            upstreams.append(
                UpstreamClass(
                    dataset=upstream_urn,
                    type="TRANSFORMED",
                )
            )

        if upstreams:
            lineage = UpstreamLineageClass(upstreams=upstreams)
            emitter.emit(
                MetadataChangeProposalWrapper(
                    entityUrn=dataset_urn,
                    aspect=lineage,
                )
            )

    return dataset_urn


def register_dataproduct(dp: DataProduct, dataset_urn: str) -> str:
    # Data product URN convention: domain.name
    data_product_urn = f"urn:li:dataProduct:{dp.domain}.{dp.name}"

    props = DataProductPropertiesClass(
        name=dp.display_name,
        description=dp.description,
        domain=f"urn:li:domain:{dp.domain}",
        entities=[dataset_urn],
    )

    emitter.emit(
        MetadataChangeProposalWrapper(
            entityUrn=data_product_urn,
            aspect=props,
        )
    )

    return data_product_urn


# ---------- API endpoint ----------

@app.post("/data-products")
def create_data_product(req: DataProductRequest):
    try:
        raw = yaml.safe_load(req.contract_yaml)
        contract = DataProductContract.parse_obj(raw)
        dp = contract.data_product
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid contract: {e}")

    try:
        # 1. Snowflake physical asset
        create_or_update_snowflake_assets(dp)

        # 2. Dataset + metadata in DataHub
        dataset_urn = register_dataset_and_metadata(dp)

        # 3. Data product entity in DataHub
        dp_urn = register_dataproduct(dp, dataset_urn)

        return {
            "status": "success",
            "dataset_urn": dataset_urn,
            "data_product_urn": dp_urn,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing data product: {e}")


# ---------- Local dev entrypoint ----------

if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app:app", host="0.0.0.0", port=8000, reload=True)