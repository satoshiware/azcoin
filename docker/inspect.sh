#!/bin/sh
set -eu
p=$(command -v bitcoind)
echo "bitcoind at: $p"
ls -la "$p"
real=$(readlink -f "$p")
echo "real path: $real"
sha256sum "$real"
echo "---- bitcoind -version ----"
bitcoind -version
