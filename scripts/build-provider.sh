#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Includes native Lambda Web Function resources (unreleased 6.72).
revision=6979502b5176ee2aefab88194f2491088f049cf5
mkdir -p .terraform/provider-src .terraform/providers-dev
git -C .terraform/provider-src init -q
git -C .terraform/provider-src fetch --depth=1 https://github.com/hashicorp/terraform-provider-aws.git "$revision"
git -C .terraform/provider-src checkout --detach FETCH_HEAD
(
  cd .terraform/provider-src
  GOTOOLCHAIN=auto GOMAXPROCS=4 go build -p 4 -trimpath -ldflags='-s -w' \
    -o ../providers-dev/terraform-provider-aws .
)

cat > .terraform/provider-dev.tfrc <<EOF
provider_installation {
  dev_overrides {
    "hashicorp/aws" = "$(pwd)/.terraform/providers-dev"
  }
  direct {}
}
EOF
