"""Install Thalovant listener startup hooks into the active Python env."""

from __future__ import annotations

import shutil
import site
from pathlib import Path


MODULE = "thalovant_hivemind_listener_compat"
SOURCE = Path("/tmp") / f"{MODULE}.py"


def main() -> None:
    if not SOURCE.is_file():
        raise SystemExit(f"missing listener compat source: {SOURCE}")

    site_packages = [Path(path) for path in site.getsitepackages()]
    if not site_packages:
        raise SystemExit("no site-packages directory found")

    for package_dir in site_packages:
        package_dir.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(SOURCE, package_dir / f"{MODULE}.py")
        (package_dir / f"{MODULE}.pth").write_text(
            f"import {MODULE}\n",
            encoding="utf-8",
        )


if __name__ == "__main__":
    main()
