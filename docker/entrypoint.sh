#!/usr/bin/env bash
set -euo pipefail

DATADIR="${AZCOIN_DATA:-/data}"
CONF="${CONF:-${DATADIR}/azcoin.conf}"

P2P_PORT="${P2P_PORT:-19333}"
RPC_PORT="${RPC_PORT:-19332}"

RPC_USER="${RPC_USER:-azrpc}"
RPC_PASSWORD="${RPC_PASSWORD:-azrpcpass}"

# Main-chain native AZCoin binary
DAEMON="${DAEMON:-azcoind}"

# Pick ONE chain selector:
#   CHAIN=regtest -> uses -regtest
#   CHAIN=testnet -> uses -testnet
#   CHAIN=signet  -> uses -signet
#   CHAIN=main    -> uses nothing
CHAIN="${CHAIN:-main}"

mkdir -p "${DATADIR}"

# Create a minimal conf if missing
if [ ! -f "${CONF}" ]; then
  if [ -z "${RPC_PASSWORD}" ] || [ "${RPC_PASSWORD}" = "change_me" ] || [ "${RPC_PASSWORD}" = "azrpcpass" ]; then
    if command -v openssl >/dev/null 2>&1; then
      RPC_PASSWORD="$(openssl rand -base64 32)"
    else
      RPC_PASSWORD="$(head -c 48 /dev/urandom | base64)"
    fi
    echo "INFO: Generated unique RPC_PASSWORD for this node and wrote it to ${CONF}." >&2
  fi

  cat > "${CONF}" <<CONFEOF
server=1
txindex=1
printtoconsole=1
rpcuser=${RPC_USER}
rpcpassword=${RPC_PASSWORD}
rpcbind=0.0.0.0
rpcallowip=0.0.0.0/0
port=${P2P_PORT}
rpcport=${RPC_PORT}
addnode=azcoin_node1.satoshiware.org:19333
CONFEOF
fi

chain_args=()
case "${CHAIN}" in
  regtest) chain_args=(-regtest) ;;
  testnet) chain_args=(-testnet) ;;
  signet)  chain_args=(-signet) ;;
  main|mainnet|"") chain_args=() ;;
  *)
    echo "Unknown CHAIN=${CHAIN} (use regtest|testnet|signet|main)"
    exit 1
    ;;
esac

# Optional bootstrap/peering controls
extra_args=()
if [ -n "${SEEDNODE_HOST:-}" ]; then
  seed_port="${SEEDNODE_PORT:-$P2P_PORT}"
  extra_args+=("-seednode=${SEEDNODE_HOST}:${seed_port}")
fi
if [ -n "${CONNECT_TO:-}" ]; then
  extra_args+=("-connect=${CONNECT_TO}")
fi
if [ -n "${ADDNODE:-}" ]; then
  addnodes="${ADDNODE//,/ }"
  # shellcheck disable=SC2206
  nodes=($addnodes)
  for n in "${nodes[@]}"; do
    [ -n "$n" ] && extra_args+=("-addnode=$n")
  done
fi

if [ "${1:-}" = "azcoind" ]; then
  shift
fi

exec "${DAEMON}" \
  "${chain_args[@]}" \
  -datadir="${DATADIR}" \
  -conf="${CONF}" \
  -printtoconsole \
  "${extra_args[@]}" \
  "$@"