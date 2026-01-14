#!/usr/bin/env bash
set -euo pipefail

DATADIR="${AZCOIN_DATA:-/data}"
CONF="${CONF:-${DATADIR}/azcoin.conf}"

P2P_PORT="${P2P_PORT:-19333}"
RPC_PORT="${RPC_PORT:-19332}"

RPC_USER="${RPC_USER:-azrpc}"
RPC_PASSWORD="${RPC_PASSWORD:-azrpcpass}"

# Pick ONE chain selector:
#   CHAIN=micro   -> uses -chain=micro -micro=<name>
#   CHAIN=regtest -> uses -regtest
#   CHAIN=testnet -> uses -testnet
#   CHAIN=signet  -> uses -signet
#   CHAIN=main    -> uses nothing
CHAIN="${CHAIN:-micro}"

MICRO="${MICRO:-azcoin}"
DAEMON="${DAEMON:-bitcoind}"

mkdir -p "${DATADIR}"

# Create a minimal conf if missing
if [ ! -f "${CONF}" ]; then
  cat > "${CONF}" <<EOF
server=1
txindex=1
printtoconsole=1

[micro]
rpcuser=${RPC_USER}
rpcpassword=${RPC_PASSWORD}
rpcbind=0.0.0.0
rpcallowip=0.0.0.0/0

port=${P2P_PORT}
rpcport=${RPC_PORT}
EOF
fi

chain_args=()
case "${CHAIN}" in
  micro)   chain_args=(-chain=micro -micro="${MICRO}") ;;
  regtest) chain_args=(-regtest) ;;
  testnet) chain_args=(-testnet) ;;
  signet)  chain_args=(-signet) ;;
  main|mainnet|"") chain_args=() ;;
  *) echo "Unknown CHAIN=${CHAIN} (use micro|regtest|testnet|signet|main)"; exit 1 ;;
esac

exec "${DAEMON}" \
  -chain=micro \
  -micro="${MICRO}" \
  -datadir="${DATADIR}" \
  -conf="${CONF}" \
  -printtoconsole \
  "$@"
