#!/usr/bin/env bash
set -Eeuo pipefail

KUBECONFIG_PATH="${KUBECONFIG_PATH:-$HOME/.kube/northstar-floci-k3s.yaml}"
LOG_DIR="${LOG_DIR:-$HOME/.northstar/logs}"
PID_DIR="${PID_DIR:-$HOME/.northstar/pids}"

FLOCI_CONTAINER="floci"
ECR_CONTAINER="floci-ecr-registry"
K3S_CONTAINER="floci-eks-northstar-dev"

EXPECTED_K3S_BRIDGE_IP="172.17.0.4"

mkdir -p "$LOG_DIR" "$PID_DIR"

export KUBECONFIG="$KUBECONFIG_PATH"

ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*"; }
fail() { printf '\033[31m✗\033[0m %s\n' "$*" >&2; }

start_container() {
    local name="$1"

    if ! docker inspect "$name" >/dev/null 2>&1; then
        fail "Required Docker container '$name' does not exist."
        exit 1
    fi

    if [[ "$(docker inspect -f '{{.State.Running}}' "$name")" == "true" ]]; then
        ok "$name already running"
    else
        echo "Starting $name..."
        docker start "$name" >/dev/null
        ok "$name started"
    fi
}

wait_for_container() {
    local name="$1"

    for attempt in {1..30}; do
        if [[ "$(docker inspect -f '{{.State.Running}}' "$name" 2>/dev/null || true)" == "true" ]]; then
            return 0
        fi
        sleep 1
    done

    fail "$name did not stay running."
    docker logs --tail=100 "$name" || true
    exit 1
}

start_forward() {
    local name="$1"
    local namespace="$2"
    local resource="$3"
    local ports="$4"

    local pid_file="$PID_DIR/$name.pid"
    local log_file="$LOG_DIR/$name.log"

    if [[ -f "$pid_file" ]]; then
        local pid
        pid="$(cat "$pid_file")"

        if kill -0 "$pid" 2>/dev/null; then
            ok "$name port-forward already running (PID $pid)"
            return 0
        fi

        rm -f "$pid_file"
    fi

    kubectl port-forward \
        -n "$namespace" \
        "$resource" \
        "$ports" \
        >"$log_file" 2>&1 &

    local pid=$!
    echo "$pid" > "$pid_file"

    sleep 2

    if kill -0 "$pid" 2>/dev/null; then
        ok "$name port-forward started (PID $pid)"
    else
        fail "$name port-forward failed"
        echo "See $log_file"
        rm -f "$pid_file"
    fi
}

echo
echo "=========================================="
echo " NorthStar SRE Platform Startup"
echo "=========================================="
echo

echo "[1/8] Docker"

if ! docker info >/dev/null 2>&1; then
    fail "Docker is not reachable."
    echo "Start Docker Desktop, then rerun this script."
    exit 1
fi

ok "Docker is healthy"

echo
echo "[2/8] NorthStar Docker infrastructure"

# Startup order is intentional.
# The existing K3s cluster persisted node identity 172.17.0.4.
# FLOCi and the registry must occupy .2 and .3 first.

start_container "$FLOCI_CONTAINER"
wait_for_container "$FLOCI_CONTAINER"

start_container "$ECR_CONTAINER"
wait_for_container "$ECR_CONTAINER"

sleep 2

start_container "$K3S_CONTAINER"
wait_for_container "$K3S_CONTAINER"

echo
echo "Docker addresses:"

docker inspect \
    "$FLOCI_CONTAINER" \
    "$ECR_CONTAINER" \
    "$K3S_CONTAINER" \
    --format '{{.Name}} -> {{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}'

K3S_BRIDGE_IP="$(
    docker inspect "$K3S_CONTAINER" \
      --format '{{(index .NetworkSettings.Networks "bridge").IPAddress}}'
)"

if [[ "$K3S_BRIDGE_IP" != "$EXPECTED_K3S_BRIDGE_IP" ]]; then
    fail "Unexpected K3s bridge IP: $K3S_BRIDGE_IP"
    echo "Expected: $EXPECTED_K3S_BRIDGE_IP"
    echo
    echo "Stopping K3s to avoid cluster networking failure."
    docker stop "$K3S_CONTAINER" >/dev/null || true
    exit 1
fi

ok "K3s recovered expected bridge IP: $K3S_BRIDGE_IP"

echo
echo "[3/8] Kubeconfig"

if [[ ! -f "$KUBECONFIG" ]]; then
    fail "Kubeconfig not found: $KUBECONFIG"
    exit 1
fi

ok "Using $KUBECONFIG"

echo
echo "[4/8] Kubernetes API"

for attempt in {1..60}; do
    if kubectl get nodes >/dev/null 2>&1; then
        ok "Kubernetes API reachable"
        break
    fi

    if [[ "$attempt" -eq 60 ]]; then
        fail "Kubernetes API did not become reachable."
        docker logs --tail=150 "$K3S_CONTAINER" || true
        exit 1
    fi

    sleep 2
done

kubectl wait \
    --for=condition=Ready \
    node \
    --all \
    --timeout=180s >/dev/null

ok "Kubernetes node Ready"

echo
echo "[5/8] NorthStar application"

kubectl get pods -n northstar-dev

if ! kubectl wait \
    --for=condition=Ready \
    pod \
    --all \
    -n northstar-dev \
    --timeout=180s; then
    warn "Some northstar-dev Pods are not Ready."
fi

echo
echo "[6/8] Monitoring"

kubectl get pods -n monitoring || warn "Monitoring namespace unavailable"

echo
echo "[7/8] Logging"

kubectl get pods -n logging || warn "Logging namespace unavailable"

echo
echo "[8/8] Local access"

start_forward \
    checkout \
    kube-system \
    service/northstar-traefik \
    18080:80

start_forward \
    grafana \
    monitoring \
    service/northstar-monitoring-grafana \
    3000:80

start_forward \
    loki \
    logging \
    service/northstar-loki-gateway \
    3100:80

echo
echo "=========================================="
echo " NorthStar startup complete"
echo "=========================================="
echo
echo "Checkout : http://127.0.0.1:18080"
echo "Grafana  : http://127.0.0.1:3000"
echo "Loki     : http://127.0.0.1:3100"
echo
echo "Logs     : $LOG_DIR"
echo
