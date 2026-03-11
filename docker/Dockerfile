# syntax=docker/dockerfile:1.6
  FROM debian:testing-slim
  
  ARG DEBIAN_FRONTEND=noninteractive
  ARG AZCOIN_VERSION=Latest
  ARG AZCOIN_TARBALL_URL=https://github.com/satoshiware/azcoin/releases/download/Latest/azcoin-x86_64-linux-gnu.tar.gz
  ARG AZCOIN_TARBALL=azcoin-x86_64-linux-gnu.tar.gz
  ARG AZCOIN_SHA256=""
  
  ENV AZCOIN_DATA=/data
  
  RUN apt-get update && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      gosu \
      libgcc-s1 \
      libsqlite3-0 \
      libstdc++6 \
      openssl \
      tar \
      tini \
      xz-utils \
   && rm -rf /var/lib/apt/lists/*
  
  RUN useradd -r -m -u 10001 -s /usr/sbin/nologin azcoin \
   && mkdir -p /data /opt/azcoin-download \
   && chown -R azcoin:azcoin /data
  
  WORKDIR /opt/azcoin-download
  
  RUN set -eux; \
      curl -fL "${AZCOIN_TARBALL_URL}" -o "${AZCOIN_TARBALL}"; \
      if [ -n "${AZCOIN_SHA256}" ]; then \
        echo "${AZCOIN_SHA256}  ${AZCOIN_TARBALL}" | sha256sum -c -; \
      fi; \
      tar -xzf "${AZCOIN_TARBALL}"; \
      if [ -d "./azcoin-install/bin" ]; then \
        BIN_DIR="./azcoin-install/bin"; \
      else \
        BIN_DIR="$(find . -type f -name azcoind -exec dirname {} \; | head -n 1)"; \
      fi; \
      test -n "${BIN_DIR}"; \
      test -f "${BIN_DIR}/azcoind"; \
      test -f "${BIN_DIR}/azcoin-cli"; \
      test -f "${BIN_DIR}/azcoin-tx"; \
      install -m 0755 "${BIN_DIR}/azcoind" /usr/local/bin/azcoind; \
      install -m 0755 "${BIN_DIR}/azcoin-cli" /usr/local/bin/azcoin-cli; \
      install -m 0755 "${BIN_DIR}/azcoin-tx" /usr/local/bin/azcoin-tx; \
      if [ -f "${BIN_DIR}/azcoin-wallet" ]; then install -m 0755 "${BIN_DIR}/azcoin-wallet" /usr/local/bin/azcoin-wallet; fi; \
      if [ -f "${BIN_DIR}/azcoin-util" ]; then install -m 0755 "${BIN_DIR}/azcoin-util" /usr/local/bin/azcoin-util; fi; \
      rm -rf /opt/azcoin-download
  
  COPY docker/entrypoint.sh /usr/local/bin/docker-entrypoint.sh
  COPY docker/azcoin-cli /usr/local/bin/azcoin-cli-wrapper
  
  RUN chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/azcoin-cli-wrapper
  
  VOLUME ["/data"]
  EXPOSE 19333 19332
  
  ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
  CMD []
  