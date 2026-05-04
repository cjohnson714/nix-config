#!/usr/bin/env python3
"""Inject a block device path into our disko scheme placeholder (robust vs shell/sed)."""
from __future__ import annotations

import pathlib
import sys

NEEDLE = 'lib.mkDefault "/dev/disk/by-id/CHANGE_ME"'


def main() -> None:
    if len(sys.argv) != 4:
        print("usage: render_disko.py <scheme.nix> <device> <out.nix>", file=sys.stderr)
        raise SystemExit(2)
    src, dev, out = sys.argv[1:4]
    text = pathlib.Path(src).read_text(encoding="utf-8")
    if NEEDLE not in text:
        print(f"error: placeholder not found in {src}", file=sys.stderr)
        raise SystemExit(1)
    escaped = dev.replace("\\", "\\\\").replace('"', '\\"')
    text = text.replace(NEEDLE, f'lib.mkDefault "{escaped}"', 1)
    pathlib.Path(out).write_text(text, encoding="utf-8")


if __name__ == "__main__":
    main()
