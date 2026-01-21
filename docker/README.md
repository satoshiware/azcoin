# Production Docker (one node per machine)

This folder is for **running AZCoin nodes in production** using a **prebuilt image from a registry**.

- `contrib/docker/` stays as the **local dev/test multi-node sandbox** (it builds locally).
- `docker/` is **build once, run everywhere** (no local build during deployment).

## Prereqs

- Docker Engine + Docker Compose v2
- A published image in a registry (GHCR/DockerHub/private)

## Files

- `docker-compose.yml` — single-node compose (pulls `AZCOIN_IMAGE`)
- `env.example` — copy to `.env` and edit

## Usage (per machine)

```bash
cd docker
cp .\env.example .env
# edit .env
docker compose pull
docker compose up -d
docker compose logs -f azcoin
```

## Notes

- RPC is **not published** by default. If you need local RPC access on the host,
  uncomment the `127.0.0.1:${RPC_PORT}:${RPC_PORT}` mapping in `docker-compose.yml`.
- To bootstrap into an existing network without relying on Docker-only peers, set:
  - `SEEDNODE_HOST=<your-seed-dns-or-ip>` (recommended), or
  - `CONNECT_TO=<ip-or-host:port>` (strict mode; connects only to that node).

