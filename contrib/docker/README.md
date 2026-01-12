# AZCoin Core Docker (local test network)

This folder provides a Docker build and a docker-compose setup for running a small multi-node AZCoin network for testing.

## Files
- `Dockerfile` — multi-stage build (builder + runtime)
- `entrypoint.sh` — runs the daemon with safe defaults
- `docker-compose.yml` — seed + 2 peers on a private Docker network

## Quick start (local)

From the repo root:

```bash
docker compose -f contrib/docker/docker-compose.yml up -d --build
docker compose -f contrib/docker/docker-compose.yml logs -f seed
