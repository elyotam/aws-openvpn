#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLE_DIR="$ROOT_DIR/examples/terraform"

if [ ! -f "$EXAMPLE_DIR/terraform.tfvars" ]; then
  echo "Missing examples/terraform/terraform.tfvars" >&2
  echo "Copy terraform.tfvars.example and replace every placeholder before running this script." >&2
  exit 1
fi

terraform -chdir="$EXAMPLE_DIR" init
terraform -chdir="$EXAMPLE_DIR" plan
