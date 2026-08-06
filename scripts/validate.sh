#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

terraform -chdir="$ROOT_DIR" fmt -check -recursive
terraform -chdir="$ROOT_DIR" init -backend=false
terraform -chdir="$ROOT_DIR" validate

terraform -chdir="$ROOT_DIR/examples/terraform" init -backend=false
terraform -chdir="$ROOT_DIR/examples/terraform" validate

echo "Terraform formatting and validation completed successfully."
