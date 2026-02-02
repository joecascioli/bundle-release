#!/usr/bin/env bash
set -euo pipefail

ZIP_PATH=${1:-}
JSON_PATH=${2:-}

if [[ -z "$ZIP_PATH" || -z "$JSON_PATH" ]]; then
  echo "Usage: $0 <bundle.zip> <bundle.json>" >&2
  exit 2
fi

if [[ ! -f "$ZIP_PATH" ]]; then
  echo "Missing bundle zip: $ZIP_PATH" >&2
  exit 1
fi

if [[ ! -f "$JSON_PATH" ]]; then
  echo "Missing bundle manifest: $JSON_PATH" >&2
  exit 1
fi

forbidden_patterns=(
  "\.env$"
  "\.env\."
  "(^|/)secrets\."
  "\.pem$"
  "\.key$"
)

zip_listing=$(unzip -l "$ZIP_PATH")

for pattern in "${forbidden_patterns[@]}"; do
  if echo "$zip_listing" | grep -E -q "$pattern"; then
    echo "Forbidden file pattern '$pattern' found in bundle." >&2
    exit 1
  fi
done

python3 - <<PY
import json
import sys

path = "${JSON_PATH}"
with open(path, "r", encoding="utf-8") as handle:
    data = json.load(handle)

required = ["sha", "timestamp", "artifacts"]
missing = [key for key in required if key not in data]
if missing:
    raise SystemExit(f"Missing keys in manifest: {', '.join(missing)}")

if "zip" not in data.get("artifacts", {}):
    raise SystemExit("Manifest artifacts.zip missing")

print("Bundle manifest OK")
PY

echo "Bundle checks passed"
