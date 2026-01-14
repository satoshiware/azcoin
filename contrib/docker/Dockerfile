# syntax=docker/dockerfile:1.6

############################
# 1) Builder stage
############################
FROM debian:12-slim AS builder
ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH
ARG MICRO=azcoin

WORKDIR /src

# Build deps (Bitcoin Core style)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    curl \
    file \
    bash \
    dos2unix \
    autotools-dev \
    build-essential \
    pkg-config \
    autoconf \
    automake \
    libtool \
    bsdmainutils \
    python3 \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy source
WORKDIR /src
COPY . .

# Use bash for subsequent RUN commands (needed for < <(...) process substitution)
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# normalize scripts in depends (covers no-extension scripts via shebang)
RUN set -eux; \
  find depends \
    \( -path "depends/work" -o -path "depends/built" -o -path "depends/sources" -o -path "depends/sdk-sources" -o -path "depends/SDKs" -o -path "depends/cache" \) -prune -o \
    -type f \( -name "*.sh" -o -name "*.mk" -o -name "*.in" -o -name "Makefile*" \) -print0 \
    | xargs -0 -r dos2unix -q; \
  \
  # shebang scripts without extension
  while IFS= read -r -d '' f; do \
    head -c 2 "$f" | grep -q "^#!" && dos2unix -q "$f" || true; \
  done < <(find depends \
    \( -path "depends/work" -o -path "depends/built" -o -path "depends/sources" -o -path "depends/sdk-sources" -o -path "depends/SDKs" -o -path "depends/cache" \) -prune -o \
    -type f -print0); \
  \
  # normalize common build scripts/makefiles in repo
  find . -type f \( -name "*.sh" -o -name "Makefile*" -o -name "*.mk" -o -name "*.am" -o -name "*.in" \) -print0 \
    | xargs -0 -r dos2unix -q; \
  \
  # normalize C/C++ sources
  find src -type f \( -name "*.c" -o -name "*.cc" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \) -print0 \
    | xargs -0 -r dos2unix -q

# Ensure depends has config.guess/config.sub (some forks/checkouts miss these)
RUN cp -f /usr/share/misc/config.guess /src/depends/config.guess && \
    cp -f /usr/share/misc/config.sub   /src/depends/config.sub && \
    chmod +x /src/depends/config.guess /src/depends/config.sub

# Select micro (required for your build)
RUN test -f "./src/micros/micro_${MICRO}.h" \
 && ln -sf "micros/micro_${MICRO}.h" "./src/micro.h"

# Map Docker arch -> depends HOST triplet
RUN : "${TARGETARCH:=amd64}" && \
    case "${TARGETARCH}" in \
      "amd64") echo "x86_64-pc-linux-gnu" > /tmp/host ;; \
      "arm64") echo "aarch64-linux-gnu" > /tmp/host ;; \
      *) echo "Unsupported TARGETARCH=${TARGETARCH}" && exit 1 ;; \
    esac

# Build using depends + autotools, install into /opt/stage
RUN HOST="$(cat /tmp/host)" && \
    make -C depends clean || true && \
    make -C depends HOST="$HOST" NO_QT=1 NO_QR=1 NO_UPNP=1 NO_NATPMP=1 -j"$(nproc)" && \
    ./autogen.sh && \
    CONFIG_SITE="$PWD/depends/$HOST/share/config.site" ./configure \
      --disable-tests \
      --disable-bench \
      --without-gui \
      --prefix=/usr/local && \
    make -j"$(nproc)" && \
    make install DESTDIR=/opt/stage

############################
# 2) Runtime stage
############################
FROM debian:12-slim AS runtime
ARG DEBIAN_FRONTEND=noninteractive

# Minimal runtime deps (adjust if ldd shows missing libs)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libstdc++6 \
    libgcc-s1 \
    libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -r -m -u 10001 -s /usr/sbin/nologin azcoin

# Data directory
ENV AZCOIN_DATA=/data
RUN mkdir -p /data && chown -R azcoin:azcoin /data
VOLUME ["/data"]

# P2P / RPC
EXPOSE 19333 19332

# Copy installed binaries + libs
COPY --from=builder /opt/stage/usr/local/ /usr/local/

# Entrypoint
COPY contrib/docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER azcoin
ENTRYPOINT ["/entrypoint.sh"]
CMD ["-printtoconsole"]
