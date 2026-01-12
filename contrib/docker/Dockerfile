# syntax=docker/dockerfile:1.6

############################
# 1) Builder stage
############################
FROM debian:12-slim AS builder

ARG DEBIAN_FRONTEND=noninteractive

# ---- Build deps (adjust to match your build script/toolchain) ----
# NOTE: keep this list tight; add packages only when the build complains.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    build-essential \
    pkg-config \
    autoconf \
    automake \
    libtool \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# ---- Copy source ----
WORKDIR /src
COPY . .

# ---- Build ----
# TODO: Replace with your actual build script or build commands.
# Examples (pick one):
#  A) If you have a script: RUN ./contrib/scripts/build-debian.sh
#  B) Classic autotools:    RUN ./autogen.sh && ./configure && make -j"$(nproc)"
RUN echo "TODO: wire your AZCoin build here" && exit 1

############################
# 2) Runtime stage
############################
FROM debian:12-slim AS runtime

ARG DEBIAN_FRONTEND=noninteractive

# Runtime deps (adjust if ldd shows missing libs)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1000 -s /bin/bash azcoin

# Data directory
ENV AZCOIN_DATA=/data
VOLUME ["/data"]

# P2P / RPC (update to your actual RPC port)
EXPOSE 19333 19332

# Copy binaries from builder stage
# TODO: Update paths + names once you know where your build puts them.
# Example:
# COPY --from=builder /src/src/azcoind /usr/local/bin/azcoind
# COPY --from=builder /src/src/azcoin-cli /usr/local/bin/azcoin-cli

# Entrypoint
COPY contrib/docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# Default command can be overridden by docker run args
CMD ["-printtoconsole"]
