#!/usr/bin/env python3
import argparse
import json
import sys
from pathlib import Path

SETTINGS = Path.home() / ".claude" / "settings.json"


def parse_value(raw: str):
    normalized = raw.strip()
    lowered = normalized.lower()
    if lowered == "true":
        return True
    if lowered == "false":
        return False
    try:
        return json.loads(normalized)
    except json.JSONDecodeError:
        if "," in normalized:
            return [v.strip() for v in normalized.split(",")]
        return normalized


def assign_nested(obj: dict, keys: list[str], value) -> None:
    for key in keys[:-1]:
        child = obj.setdefault(key, {})
        if not isinstance(child, dict):
            raise SystemExit(f"error: '{key}' exists and is not an object")
        obj = child
    obj[keys[-1]] = value


def main() -> None:
    parser = argparse.ArgumentParser(
        description=f"Set a key in {SETTINGS}",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Values are parsed as JSON when possible (numbers, arrays, objects).\n"
            "true/false (any case) become booleans. Comma-separated values become arrays.\n"
            "Everything else is a string."
        ),
    )
    parser.add_argument("key", help="dot-notation key (e.g. env.ENABLE_TOOL_SEARCH)")
    parser.add_argument(
        "value", help="value to set (JSON, comma-separated value, or plain string)"
    )
    args = parser.parse_args()

    key = args.key
    value = parse_value(args.value)

    SETTINGS.parent.mkdir(parents=True, exist_ok=True)
    try:
        with SETTINGS.open() as f:
            data: dict = json.load(f)
    except FileNotFoundError:
        data = {}
    except json.JSONDecodeError as e:
        print(f"error: {SETTINGS} contains invalid JSON: {e}", file=sys.stderr)
        sys.exit(1)

    assign_nested(data, key.split("."), value)

    _ = SETTINGS.write_text(json.dumps(data, indent=2) + "\n")
    print(f"set {key} = {json.dumps(value)}")


if __name__ == "__main__":
    main()
