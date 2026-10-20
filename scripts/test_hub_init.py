#!/usr/bin/env python3
"""The self-host hub bootstrap grants a bridge client both utterance spellings.

HIVEMIND-POLICY-1 §4: a message whose msg_type is not in the client's whitelist
is denied, and the whitelist names what a client may send. The bootstrap mints
clients only for bridges, and every bridge sends recognizer_loop:utterance.
The ovos.utterance.handle grant (OVOS-PIPELINE-1 §9.1) is forward compatibility:
a bridge that moves to the current topic is not denied. A client receives
`speak` without a grant, so the bootstrap does not grant it.

Run: python3 scripts/test_hub_init.py
"""
import os
import stat
import subprocess
import tempfile
import unittest
from pathlib import Path

HUB_INIT = Path(__file__).resolve().parent.parent / "selfhost" / "bootstrap" / "hub-init.sh"

STUB = """#!/bin/sh
echo "$@" >> "$CALLS"
case "$1" in
  add-client) printf 'Node ID: 7\\nAccess Key: ak\\nPassword: pw\\n' ;;
esac
"""


class HubInitGrantTests(unittest.TestCase):
    def granted(self, bridge: str) -> list:
        """Run hub-init.sh against a stub hivemind-core; return the types allowed for node 7."""
        with tempfile.TemporaryDirectory() as tmp:
            bin_dir = Path(tmp) / "bin"
            bin_dir.mkdir()
            stub = bin_dir / "hivemind-core"
            stub.write_text(STUB)
            stub.chmod(stub.stat().st_mode | stat.S_IEXEC)
            calls = Path(tmp) / "calls"
            env = {"PATH": f"{bin_dir}:/usr/bin:/bin", "CALLS": str(calls),
                   "CREDS_DIR": str(Path(tmp) / "creds"), "HIVEMIND_BRIDGES": bridge}
            result = subprocess.run(["bash", str(HUB_INIT)], env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            lines = [line.split() for line in calls.read_text().splitlines()]
            return [words[1] for words in lines if words[0] == "allow-msg" and words[2] == "7"]

    def test_a_bridge_is_granted_the_current_and_the_legacy_utterance_topic(self):
        allowed = self.granted("matrix")
        self.assertIn("ovos.utterance.handle", allowed)
        self.assertIn("recognizer_loop:utterance", allowed)
        self.assertNotIn("speak", allowed)

    def test_the_hub_configuration_is_never_grantable_by_the_bootstrap(self):
        self.assertNotIn("configuration.patch", self.granted("media-player"))

    def test_the_media_player_keeps_its_playback_types(self):
        allowed = self.granted("media-player")
        self.assertIn("ovos.utterance.handle", allowed)
        self.assertIn("ovos.common_play.play", allowed)


if __name__ == "__main__":
    unittest.main()
