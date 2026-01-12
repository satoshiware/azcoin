#!/usr/bin/env bash
set -euo pipefail

# This entrypoint:
# - Ensures /data exists and is writable
# - Drops privileges to non-root
# - Starts azcoind (or bitcoind) with sane defaults
#
# TODO: Confirm daemon binary name: azcoind vs bitcoind

DAEMON_BIN="${DAEMON_BIN:-azcoind}"
DATA_DIR="${AZCOIN_DATA:-/data}"

# Create datadir if missing
mkdir -p "$DATA_DIR"
chown -R azcoin:azcoin "$DATA_DIR" || true

# Default flags (override by passing args to docker run)
DEFAULT_ARGS=(
  "-datadir=${DATA_DIR}"
  "-printtoconsole"
  "-server=1"
)

# If user passed an explicit command like "bash", honor it.
if [[ "${1:-}" == "bash" || "${1:-}" == "sh" ]]; then
  exec "$@"
fi

# If first arg looks like a flag, run daemon with flags
if [[ "${1:-}" == -* ]]; then
  exec gosu azcoin "${DAEMON_BIN}" "${DEFAULT_ARGS[@]}" "$@"
fi

# Otherwise assume they passed a full command
exec "$@"
