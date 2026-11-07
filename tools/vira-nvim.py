#!/usr/bin/env python3
"""Generate Neovim theme data from the installed VS Code Vira Theme extension.

Each variant is written to home/dot_config/nvim/lua/vira/variants/<variant>.json as
the extension's own theme JSON (comments removed, keys in source order) plus a
"_source" entry recording where it came from. lua/vira/init.lua turns that data
into highlight groups; nothing in the JSON is edited by hand.

Examples:
    tools/vira-nvim.py --list              # show the extension's variants
    tools/vira-nvim.py                     # regenerate every variant
    tools/vira-nvim.py --variant palenight # regenerate only the named variant(s)

This tool is not deployed: tools/ is outside the chezmoi source state (home/).
"""

import argparse
import json
import re
import sys
from pathlib import Path

EXTENSION_ID = "vira.vsc-vira-theme"
EXTENSION_ROOTS = (
    "~/.vscode/extensions",
    "~/.vscode-insiders/extensions",
    "~/.cursor/extensions",
    "~/.vscode-oss/extensions",
)
REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_OUT = REPO_ROOT / "home" / "dot_config" / "nvim" / "lua" / "vira" / "variants"


def strip_jsonc(text):
    """Remove // and /* */ comments and trailing commas, outside strings."""
    text = text.lstrip("﻿")
    without_comments = []
    i, n, in_string = 0, len(text), False
    while i < n:
        char = text[i]
        if in_string:
            without_comments.append(char)
            if char == "\\" and i + 1 < n:
                without_comments.append(text[i + 1])
                i += 2
                continue
            if char == '"':
                in_string = False
            i += 1
        elif char == '"':
            in_string = True
            without_comments.append(char)
            i += 1
        elif text.startswith("//", i):
            end = text.find("\n", i)
            i = n if end == -1 else end
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            if end == -1:
                raise ValueError("unterminated /* comment")
            i = end + 2
        else:
            without_comments.append(char)
            i += 1

    source = "".join(without_comments)
    result = []
    i, n, in_string = 0, len(source), False
    while i < n:
        char = source[i]
        if in_string:
            result.append(char)
            if char == "\\" and i + 1 < n:
                result.append(source[i + 1])
                i += 2
                continue
            if char == '"':
                in_string = False
        elif char == '"':
            in_string = True
            result.append(char)
        elif char == ",":
            following = source[i + 1 :].lstrip()
            if not following.startswith(("}", "]")):
                result.append(char)
        else:
            result.append(char)
        i += 1
    return "".join(result)


def load_jsonc(path):
    return json.loads(strip_jsonc(path.read_text(encoding="utf-8")))


def version_key(version):
    return tuple(int(part) if part.isdigit() else 0 for part in re.split(r"[.-]", version))


def find_extension(explicit):
    if explicit:
        extension = Path(explicit).expanduser()
        if not (extension / "package.json").is_file():
            sys.exit(f"vira-nvim: no package.json in {extension}")
        return extension

    candidates = []
    for root in EXTENSION_ROOTS:
        for extension in Path(root).expanduser().glob(EXTENSION_ID + "-*"):
            package = extension / "package.json"
            if package.is_file():
                candidates.append((version_key(load_jsonc(package).get("version", "0")), extension))
    if not candidates:
        roots = ", ".join(EXTENSION_ROOTS)
        sys.exit(f"vira-nvim: {EXTENSION_ID} not found under {roots}; pass --extension DIR")
    return max(candidates)[1]


def variant_key(theme_path):
    stem = re.sub(r"^Vira-Theme-", "", theme_path.stem)
    return re.sub(r"[^a-z0-9]+", "-", stem.lower()).strip("-")


def list_variants(extension):
    package = load_jsonc(extension / "package.json")
    paths = [
        (extension / entry["path"]).resolve()
        for entry in package.get("contributes", {}).get("themes", [])
        if "path" in entry
    ]
    if not paths:
        paths = sorted(extension.rglob("Vira-Theme-*.json"))
    variants = {}
    for path in paths:
        variants.setdefault(variant_key(path), path)
    return package, variants


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--extension", help="extension directory (default: newest installed)")
    parser.add_argument("--out", default=str(DEFAULT_OUT), help="output directory (default: %(default)s)")
    selection = parser.add_mutually_exclusive_group()
    selection.add_argument("--variant", action="append", help="write only this variant; repeatable (default: all)")
    selection.add_argument("--list", action="store_true", help="list variants and exit")
    args = parser.parse_args()

    extension = find_extension(args.extension)
    package, variants = list_variants(extension)
    if not variants:
        sys.exit(f"vira-nvim: no Vira theme files in {extension}")

    out = Path(args.out)
    present = sorted(path.stem for path in out.glob("*.json")) if out.is_dir() else []

    if args.list:
        for key in sorted(variants):
            print(("* " if key in present else "  ") + key)
        return

    wanted = args.variant or sorted(variants)

    unknown = [key for key in wanted if key not in variants]
    if unknown:
        sys.exit("vira-nvim: unknown variant(s): {}; available: {}".format(
            ", ".join(unknown), ", ".join(sorted(variants))))

    source = {
        "extension": "{}.{}".format(package.get("publisher", "vira"), package.get("name", "vsc-vira-theme")),
        "version": package.get("version", "unknown"),
    }
    out.mkdir(parents=True, exist_ok=True)
    for key in wanted:
        theme = load_jsonc(variants[key])
        data = {"_source": dict(source, file=variants[key].name)}
        data.update(theme)
        target = out / (key + ".json")
        target.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(f"wrote {target} ({source['extension']} {source['version']})")


if __name__ == "__main__":
    main()
