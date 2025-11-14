#!/usr/bin/env bash
set -euo pipefail

########################################
# CONFIG DEFAULTS (edit as needed)
########################################

PROJECT_ID="${PROJECT_ID:-storied-box-478112-e8}"
REGION="${REGION:-europe-west4}"            # for regional GKE clusters
GKE_CLUSTER_NAME="${GKE_CLUSTER_NAME:-dev-datahub-gke}"
SQL_INSTANCE_NAME="${SQL_INSTANCE_NAME:-dev-datahub-sql}"

# Optional: fixed node pool & size when starting GKE
GKE_NODEPOOL="${GKE_NODEPOOL:-}"            # if empty, script will auto-detect
GKE_NODE_COUNT_START="${GKE_NODE_COUNT_START:-1}"  # how many nodes when starting


########################################
# USAGE / HELP
########################################

usage() {
  cat <<EOF
Usage: $0 <command> [options]

Commands:
  stop gke              Stop/scale down GKE nodes to 0
  stop sql              Stop Cloud SQL instance
  stop all              Stop both GKE (nodes=0) and Cloud SQL

  start gke             Start/scale up GKE nodes (to GKE_NODE_COUNT_START)
  start sql             Start Cloud SQL instance
  start all             Start both GKE and Cloud SQL

Global config (override via env vars or edit top of script):
  PROJECT_ID           (current: $PROJECT_ID)
  REGION               (current: $REGION)
  GKE_CLUSTER_NAME     (current: $GKE_CLUSTER_NAME)
  SQL_INSTANCE_NAME    (current: $SQL_INSTANCE_NAME)
  GKE_NODEPOOL         (current: ${GKE_NODEPOOL:-"<auto-detect>"})
  GKE_NODE_COUNT_START (current: $GKE_NODE_COUNT_START)

Examples:
  PROJECT_ID=my-proj REGION=europe-west4 \\
    ./gcp_infra_control.sh stop all

  ./gcp_infra_control.sh start gke
  ./gcp_infra_control.sh stop sql

Note:
  - Assumes a *regional* GKE cluster. If yours is zonal, replace --region with --zone.
EOF
  exit 1
}


########################################
# HELPER: CHECK GCLOUD & SET PROJECT
########################################

ensure_gcloud() {
  if ! command -v gcloud >/dev/null 2>&1; then
    echo "ERROR: gcloud CLI not found in PATH" >&2
    exit 1
  fi

  echo "==> Using project: $PROJECT_ID"
  gcloud config set project "$PROJECT_ID" >/dev/null
}


########################################
# GKE FUNCTIONS
########################################

get_nodepool_name() {
  if [[ -n "$GKE_NODEPOOL" ]]; then
    echo "$GKE_NODEPOOL"
    return
  fi

  echo "==> Auto-detecting node pool for cluster: $GKE_CLUSTER_NAME"
  local pool
  pool="$(gcloud container node-pools list \
    --cluster="$GKE_CLUSTER_NAME" \
    --region="$REGION" \
    --format='value(name)' | head -n1 || true)"

  if [[ -z "$pool" ]]; then
    echo "ERROR: No node pool found for cluster '$GKE_CLUSTER_NAME' in region '$REGION'" >&2
    exit 1
  fi

  echo "$pool"
}

stop_gke() {
  ensure_gcloud

  local pool
  pool="$(get_nodepool_name)"

  echo
  echo "=============================="
  echo "   SCALING GKE TO ZERO NODES"
  echo "=============================="
  echo "Cluster   : $GKE_CLUSTER_NAME"
  echo "Region    : $REGION"
  echo "Node pool : $pool"
  echo

  gcloud container clusters resize "$GKE_CLUSTER_NAME" \
    --node-pool="$pool" \
    --num-nodes=0 \
    --region="$REGION" \
    --quiet

  echo "GKE cluster '$GKE_CLUSTER_NAME' scaled to 0 nodes."
}

start_gke() {
  ensure_gcloud

  local pool
  pool="$(get_nodepool_name)"

  echo
  echo "=============================="
  echo "   STARTING GKE NODES"
  echo "=============================="
  echo "Cluster        : $GKE_CLUSTER_NAME"
  echo "Region         : $REGION"
  echo "Node pool      : $pool"
  echo "Target nodes   : $GKE_NODE_COUNT_START"
  echo

  gcloud container clusters resize "$GKE_CLUSTER_NAME" \
    --node-pool="$pool" \
    --num-nodes="$GKE_NODE_COUNT_START" \
    --region="$REGION" \
    --quiet

  echo "GKE cluster '$GKE_CLUSTER_NAME' scaled to $GKE_NODE_COUNT_START nodes."
}


########################################
# CLOUD SQL FUNCTIONS
########################################

stop_sql() {
  ensure_gcloud

  echo
  echo "=============================="
  echo "     STOPPING CLOUD SQL"
  echo "=============================="
  echo "Instance : $SQL_INSTANCE_NAME"
  echo

  # Prevent auto-start in some configs
  echo "==> Setting activation policy to NEVER"
  gcloud sql instances patch "$SQL_INSTANCE_NAME" \
    --activation-policy=NEVER \
    --quiet || true

  echo "==> Stopping Cloud SQL instance"
  gcloud sql instances stop "$SQL_INSTANCE_NAME" || true

  echo "Cloud SQL instance '$SQL_INSTANCE_NAME' stopped (or already stopped)."
}

start_sql() {
  ensure_gcloud

  echo
  echo "=============================="
  echo "     STARTING CLOUD SQL"
  echo "=============================="
  echo "Instance : $SQL_INSTANCE_NAME"
  echo

  # Optionally flip activation policy back to ALWAYS
  echo "==> Setting activation policy to ALWAYS"
  gcloud sql instances patch "$SQL_INSTANCE_NAME" \
    --activation-policy=ALWAYS \
    --quiet || true

  echo "==> Starting Cloud SQL instance"
  gcloud sql instances start "$SQL_INSTANCE_NAME" || true

  echo "Cloud SQL instance '$SQL_INSTANCE_NAME' started (or already running)."
}


########################################
# COMMAND ROUTER
########################################

if [[ $# -lt 2 ]]; then
  usage
fi

ACTION="$1"   # start | stop
TARGET="$2"   # gke | sql | all

case "$ACTION" in
  start)
    case "$TARGET" in
      gke)
        start_gke
        ;;
      sql)
        start_sql
        ;;
      all)
        start_sql
        start_gke
        ;;
      *)
        usage
        ;;
    esac
    ;;
  stop)
    case "$TARGET" in
      gke)
        stop_gke
        ;;
      sql)
        stop_sql
        ;;
      all)
        stop_gke
        stop_sql
        ;;
      *)
        usage
        ;;
    esac
    ;;
  *)
    usage
    ;;
esac