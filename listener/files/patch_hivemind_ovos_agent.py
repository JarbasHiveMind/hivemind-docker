"""Apply runtime-safe guards to hivemind-ovos-agent-plugin.

The upstream 0.3.2a1 agent iterates ``self.clients`` while other connection
callbacks can mutate it. Under live Daily Desk traffic that can raise
``RuntimeError: dictionary changed size during iteration`` and drop a request.
This keeps the wire protocol unchanged and only snapshots the local mapping
before fan-out.
"""

from __future__ import annotations

import importlib.util
from pathlib import Path


PACKAGE = "hivemind_ovos_agent_plugin"


def main() -> None:
    spec = importlib.util.find_spec(PACKAGE)
    if spec is None or spec.origin is None:
        raise SystemExit(f"{PACKAGE} is not installed")

    path = Path(spec.origin)
    source = path.read_text()

    replacements = {
        "for peer in self.clients:\n"
        "                self.clients[peer].send(hmessage)": (
            "for peer, client in list(self.clients.items()):\n"
            "                client.send(hmessage)"
        ),
        "if peer in self.clients:\n"
        "                client = self.clients[peer]\n"
        "                client.send(hmessage)\n"
        "            else:": (
            "client = self.clients.get(peer)\n"
            "            if client is not None:\n"
            "                client.send(hmessage)\n"
            "            else:"
        ),
        "for peer, client in self.clients.items():\n"
        "                if peer in target_peers:": (
            "for peer, client in list(self.clients.items()):\n"
            "                if peer in target_peers:"
        ),
    }

    patched = source
    for old, new in replacements.items():
        if old in patched:
            patched = patched.replace(old, new, 1)
        elif new not in patched:
            raise SystemExit(f"expected agent snippet not found in {path}: {old!r}")

    if patched != source:
        path.write_text(patched)


if __name__ == "__main__":
    main()
