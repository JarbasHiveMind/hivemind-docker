"""Listener process compatibility hooks.

Keep this module tiny: it is loaded through a .pth file at Python startup so
runtime compatibility shims are installed before ``hivemind-core listen`` builds
its policy chain.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path


def _install_core_refresh_forwarder() -> None:
    try:
        from hivemind_intent_quota_plugin.compat import install_core_compat

        install_core_compat()
    except Exception as exc:
        if os.environ.get("THALOVANT_LISTENER_COMPAT_STRICT") == "1":
            raise
        print(
            f"thalovant listener compat warning: {exc}",
            file=sys.stderr,
        )


def _should_install_at_startup() -> bool:
    if os.environ.get("THALOVANT_LISTENER_COMPAT_FORCE") == "1":
        return True
    return Path(sys.argv[0]).name == "hivemind-core"


def install() -> None:
    _install_core_refresh_forwarder()


if _should_install_at_startup():
    install()
