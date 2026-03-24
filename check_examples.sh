#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLE_DIR="$ROOT_DIR/example"

if [[ ! -d "$EXAMPLE_DIR" ]]; then
  echo "No example directory found at: $EXAMPLE_DIR"
  exit 1
fi

echo "Checking Dart example files in: $EXAMPLE_DIR"

mapfile -t dart_files < <(find "$EXAMPLE_DIR" -type f -name "*.dart" | sort)

if [[ ${#dart_files[@]} -eq 0 ]]; then
  echo "No .dart files found under example/"
  exit 1
fi

failed=0
ran=0
skipped=0

for file in "${dart_files[@]}"; do
  rel_path="${file#$ROOT_DIR/}"

  if rg -q "^\s*(Future<\s*void\s*>|void)\s+main\s*\(" "$file"; then
    echo ""
    echo "Running: $rel_path"
    if dart run "$file"; then
      echo "PASS: $rel_path"
      ((ran++))
    else
      echo "FAIL: $rel_path"
      ((failed++))
      ((ran++))
    fi
  else
    echo "SKIP (no main): $rel_path"
    ((skipped++))
  fi
done

echo ""
echo "Summary: ran=$ran, skipped=$skipped, failed=$failed"

if [[ $failed -eq 0 ]]; then
  echo "test passed"
  exit 0
fi

echo "test failed"
exit 1
