#!/usr/bin/env python3
"""The satellite entrypoint picks the identity the way hivemind-voice-sat does.

HIVEMIND-CRYPTO-1 §2: one identity per application. hivemind-voice-sat 2.2.6a1
keeps its own at hivemind/voice-sat/_identity.json and reads the shared
hivemind/_identity.json, with a warning, when it has none. Older releases,
which some channels still resolve, read the shared file only, and start
with no credentials if only the application file exists. The entrypoint asks
the installed launcher whether it names itself and behaves for that release:
same files, same messages, no assumption about the channel.

Run: python3 scripts/test_satellite_entrypoint.py
"""
import os
import stat
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ENTRYPOINT = ROOT / "satellite" / "files" / "entrypoint.sh"


def write_cli_stub(bin_dir: Path, shared: bool) -> None:
    """A hivemind-client that answers --help and records any other argv."""
    options = "  --app TEXT\\n" + ("  --shared\\n" if shared else "")
    stub = bin_dir / "hivemind-client"
    stub.write_text('#!/bin/sh\n'
                    f'case " $* " in *" --help "*) printf "Options:\\n{options}"; exit 0;; esac\n'
                    'echo "CLI argv: $*"\n')
    stub.chmod(stub.stat().st_mode | stat.S_IEXEC)


class SatelliteEntrypointTests(unittest.TestCase):
    def run_entrypoint(self, identity: str = None, env: dict = None,
                       names_itself: bool = True, cli_shared: bool = True) -> tuple:
        """Run the entrypoint in a fresh HOME with stubs on PATH.

        ``identity`` is "app", "shared", "both" or None. A stub hivemind-voice-sat
        records its argv and exits 0, so the entrypoint's exec is visible as its
        output. A stub python3 answers the launcher probe: exit 0 for a satellite
        that names itself, 1 for an older one. A stub hivemind-client prints
        help that lists --shared (hivemind-bus-client 1.3.0a1 and later) or not.
        """
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp) / "home"
            (home / ".config" / "hivemind").mkdir(parents=True)
            if identity in ("app", "both"):
                (home / ".config" / "hivemind" / "voice-sat").mkdir()
                (home / ".config" / "hivemind" / "voice-sat" / "_identity.json").write_text("{}")
            if identity in ("shared", "both"):
                (home / ".config" / "hivemind" / "_identity.json").write_text("{}")
            bin_dir = Path(tmp) / "bin"
            bin_dir.mkdir()
            stub = bin_dir / "hivemind-voice-sat"
            stub.write_text('#!/bin/sh\necho "STUB argv: $*"\n')
            stub.chmod(stub.stat().st_mode | stat.S_IEXEC)
            probe = bin_dir / "python3"
            probe.write_text(f'#!/bin/sh\nexit {0 if names_itself else 1}\n')
            probe.chmod(probe.stat().st_mode | stat.S_IEXEC)
            write_cli_stub(bin_dir, cli_shared)
            # the sound-server probes must fail quietly: no pw-link, no pactl on PATH
            run_env = {"HOME": str(home), "PATH": f"{bin_dir}:/usr/bin:/bin"}
            run_env.update(env or {})
            result = subprocess.run(["bash", str(ENTRYPOINT)], env=run_env,
                                    capture_output=True, text=True)
            return result.returncode, result.stdout + result.stderr

    def test_an_application_identity_starts_the_satellite_with_no_arguments(self):
        code, out = self.run_entrypoint("app")
        self.assertEqual(code, 0, out)
        self.assertIn("STUB argv: \n", out)
        self.assertNotIn("Notice", out)

    def test_a_shared_identity_starts_the_satellite_and_says_how_to_move(self):
        code, out = self.run_entrypoint("shared")
        self.assertEqual(code, 0, out)
        self.assertIn("STUB argv: \n", out)
        self.assertIn("Notice: no identity at", out)
        self.assertIn("hivemind-client --app voice-sat set-identity", out)

    def test_no_identity_and_no_credentials_refuses_with_the_app_form(self):
        code, out = self.run_entrypoint(None)
        self.assertEqual(code, 1, out)
        self.assertNotIn("STUB argv", out)
        self.assertIn("voice-sat/_identity.json", out)
        self.assertIn("hivemind-client --app voice-sat set-identity", out)
        self.assertIn("Missing: VOICE_SAT_KEY VOICE_SAT_PASSWORD VOICE_SAT_HOST", out)

    def test_an_older_satellite_ignores_the_application_file_and_uses_the_environment(self):
        creds = {"VOICE_SAT_KEY": "k", "VOICE_SAT_PASSWORD": "p", "VOICE_SAT_HOST": "ws://hub",
                 "VOICE_SAT_PORT": "5678", "HIVEMIND_SITEID": "site"}
        code, out = self.run_entrypoint("app", creds, names_itself=False)
        self.assertEqual(code, 0, out)
        self.assertIn("STUB argv: --key k --password p", out)
        self.assertIn("this satellite release reads only", out)

    def test_an_older_satellite_starts_on_the_shared_file_with_no_notice(self):
        code, out = self.run_entrypoint("both", names_itself=False)
        self.assertEqual(code, 0, out)
        self.assertIn("STUB argv: \n", out)
        self.assertNotIn("Notice", out)
        self.assertNotIn("--app", out)

    def test_an_older_satellite_with_nothing_names_the_shared_set_identity(self):
        code, out = self.run_entrypoint(None, names_itself=False)
        self.assertEqual(code, 1, out)
        self.assertIn("no identity at", out)
        self.assertIn("hivemind/_identity.json and no credentials", out)
        self.assertIn("hivemind_cli hivemind-client --shared set-identity", out)
        self.assertNotIn("--app", out)

    def test_an_older_client_with_no_shared_flag_names_the_plain_set_identity(self):
        code, out = self.run_entrypoint(None, names_itself=False, cli_shared=False)
        self.assertEqual(code, 1, out)
        self.assertIn("hivemind_cli hivemind-client set-identity", out)
        self.assertNotIn("--shared", out)

    def test_credentials_in_the_environment_start_the_satellite_with_them(self):
        code, out = self.run_entrypoint(None, {"VOICE_SAT_KEY": "k", "VOICE_SAT_PASSWORD": "p",
                                              "VOICE_SAT_HOST": "ws://hub", "VOICE_SAT_PORT": "5678",
                                              "HIVEMIND_SITEID": "site"})
        self.assertEqual(code, 0, out)
        self.assertIn("STUB argv: --key k --password p --host ws://hub --port 5678 --siteid site", out)

    def test_an_unset_port_is_not_passed_as_an_empty_argument(self):
        code, out = self.run_entrypoint(None, {"VOICE_SAT_KEY": "k", "VOICE_SAT_PASSWORD": "p",
                                               "VOICE_SAT_HOST": "ws://hub",
                                               "HIVEMIND_SITEID": "site"})
        self.assertEqual(code, 0, out)
        self.assertIn("STUB argv: --key k --password p --host ws://hub --siteid site", out)
        self.assertNotIn("--port", out)

    def test_an_unset_siteid_is_not_passed_as_an_empty_argument(self):
        code, out = self.run_entrypoint(None, {"VOICE_SAT_KEY": "k", "VOICE_SAT_PASSWORD": "p",
                                               "VOICE_SAT_HOST": "ws://hub",
                                               "VOICE_SAT_PORT": "5678"})
        self.assertEqual(code, 0, out)
        self.assertIn("STUB argv: --key k --password p --host ws://hub --port 5678", out)
        self.assertNotIn("--siteid", out)

    def test_neither_optional_argument_leaves_only_the_credentials(self):
        code, out = self.run_entrypoint(None, {"VOICE_SAT_KEY": "k", "VOICE_SAT_PASSWORD": "p",
                                               "VOICE_SAT_HOST": "ws://hub"})
        self.assertEqual(code, 0, out)
        self.assertIn("STUB argv: --key k --password p --host ws://hub\n", out)


class BridgeEntrypointTests(unittest.TestCase):
    """The chatroom and the matrix bot build their client with no identity.

    That client reads the shared hivemind/_identity.json. hivemind-bus-client
    1.3.0a1 and later write that file only with --shared, and refuse a bare
    set-identity when the file does not exist (hivemind-websocket-client#295).
    """

    def run_entrypoint(self, image: str, cli_shared: bool) -> tuple:
        with tempfile.TemporaryDirectory() as tmp:
            bin_dir = Path(tmp) / "bin"
            bin_dir.mkdir()
            write_cli_stub(bin_dir, cli_shared)
            for program in ("hivemind-flask-chatroom", "HiveMind-matrix"):
                stub = bin_dir / program
                stub.write_text('#!/bin/sh\necho "APP started"\n')
                stub.chmod(stub.stat().st_mode | stat.S_IEXEC)
            env = {"HOME": tmp, "PATH": f"{bin_dir}:/usr/bin:/bin",
                   "SAT_KEY": "k", "SAT_PASSWORD": "p", "SAT_HOST": "ws://hub", "SAT_PORT": "5678",
                   "VOICE_SAT_KEY": "k", "VOICE_SAT_PASSWORD": "p",
                   "VOICE_SAT_HOST": "ws://hub", "VOICE_SAT_PORT": "5678"}
            result = subprocess.run(["bash", str(ROOT / image / "files" / "entrypoint.sh")],
                                    env=env, capture_output=True, text=True)
            return result.returncode, result.stdout + result.stderr

    def test_a_current_client_writes_the_shared_identity_with_the_flag(self):
        for image in ("chatroom", "matrix-bot"):
            with self.subTest(image=image):
                code, out = self.run_entrypoint(image, cli_shared=True)
                self.assertEqual(code, 0, out)
                self.assertIn("CLI argv: --shared set-identity --key k --password p "
                              "--host ws://hub --port 5678\n", out)
                self.assertIn("APP started", out)

    def test_an_older_client_writes_the_shared_identity_without_the_flag(self):
        for image in ("chatroom", "matrix-bot"):
            with self.subTest(image=image):
                code, out = self.run_entrypoint(image, cli_shared=False)
                self.assertEqual(code, 0, out)
                self.assertIn("CLI argv: set-identity --key k --password p "
                              "--host ws://hub --port 5678\n", out)


class DockerfilePrereleaseTests(unittest.TestCase):
    """uv rejects --prerelease=never, so it cannot be an ARG default.

    The values uv accepts are disallow, allow, if-necessary, explicit and
    if-necessary-or-explicit. A bare "docker build" of any of these images
    takes the ARG default, and with "never" the uv step fails.
    """

    UV_VALUES = {"disallow", "allow", "if-necessary", "explicit",
                 "if-necessary-or-explicit"}

    def test_every_dockerfile_default_is_a_value_uv_accepts(self):
        root = Path(__file__).resolve().parent.parent
        defaults = {}
        for dockerfile in sorted(root.glob("*/Dockerfile")):
            for line in dockerfile.read_text().splitlines():
                if line.startswith("ARG UV_PRERELEASE="):
                    defaults[dockerfile.relative_to(root).as_posix()] = line.split("=", 1)[1]
        self.assertTrue(defaults, "no Dockerfile declares ARG UV_PRERELEASE")
        bad = {path: value for path, value in defaults.items()
               if value not in self.UV_VALUES}
        self.assertEqual(bad, {}, f"values uv rejects: {bad}")


if __name__ == "__main__":
    sys.exit(0 if unittest.main(exit=False).result.wasSuccessful() else 1)
