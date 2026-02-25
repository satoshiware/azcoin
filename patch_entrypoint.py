from pathlib import Path

p = Path("docker/entrypoint.sh")
s = p.read_text(encoding="utf-8")

needle = "rpcport=${RPC_PORT}\n"
line = "addnode=azcoin_node1.satoshiware.org:19333\n"

if line not in s:
    if needle not in s:
        raise SystemExit("Could not find rpcport line to insert after.")
    s = s.replace(needle, needle + "\n" + line)

p.write_text(s, encoding="utf-8")
print("patched:", p)
