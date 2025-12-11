from pydantic import BaseModel
from typing import List, Optional


class SchemaField(BaseModel):
    name: str
    type: str
    description: Optional[str] = None


class SnowflakeConfig(BaseModel):
    account: str
    warehouse: str
    database: str
    schema: str
    table: str
    cluster_by: Optional[List[str]] = None


class UpstreamSource(BaseModel):
    type: str   # e.g. "snowflake", "kafka"
    name: str   # identifier of the upstream dataset/stream


class AccessPolicy(BaseModel):
    group: str


class AccessPolicies(BaseModel):
    read: Optional[List[AccessPolicy]] = None
    write: Optional[List[AccessPolicy]] = None


class DataProduct(BaseModel):
    name: str
    display_name: str
    domain: str
    description: str
    owner: str
    tags: Optional[List[str]] = []
    snowflake: SnowflakeConfig
    schema: List[SchemaField]
    quality: Optional[dict] = None
    upstream_sources: Optional[List[UpstreamSource]] = None
    access_policies: Optional[AccessPolicies] = None


class DataProductContract(BaseModel):
    data_product: DataProduct