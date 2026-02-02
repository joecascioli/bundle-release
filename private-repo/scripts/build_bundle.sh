#!/usr/bin/env bash
set -euo pipefail

OUTPUT_DIR=${1:-dist}
BUNDLE_NAME=${2:-latest}

mkdir -p "$OUTPUT_DIR"

zip_path="$OUTPUT_DIR/${BUNDLE_NAME}.zip"
json_path="$OUTPUT_DIR/${BUNDLE_NAME}.json"

sha=$(git rev-parse HEAD)
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

exclude_patterns=(
  ".git/*"
  ".github/*"
  "node_modules/*"
  ".env"
  ".env.*"
  "secrets.*"
  "*.pem"
  "*.key"
)

zip -r "$zip_path" . -x "${exclude_patterns[@]}"

cat > "$json_path" <<JSON
{
  "sha": "${sha}",
  "timestamp": "${timestamp}",
  "artifacts": {
    "zip": "${BUNDLE_NAME}.zip"
  }
}
JSON

echo "Bundle created at ${zip_path}"
echo "Manifest created at ${json_path}"
