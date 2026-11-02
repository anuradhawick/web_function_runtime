#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

CI=true pnpm --dir app install --frozen-lockfile
NEXT_TELEMETRY_DISABLED=1 pnpm --dir app build

package=".terraform/lambda-build/package"
rm -rf "$package"
mkdir -p "$package"
cp -a app/.next/standalone/. "$package/"
mkdir -p "$package/.next/static" "$package/public"
cp -a app/.next/static/. "$package/.next/static/"
cp -a app/public/. "$package/public/"
cp app/lambda-entrypoint.cjs "$package/"
find "$package" -type l ! -exec test -e {} \; -delete

# Follow symlinks and count repeated files, as the ZIP provider does.
if [ "$(du -L -l -sk "$package" | cut -f1)" -gt 524288 ]; then
  echo "Deployment package exceeds 512 MiB" >&2
  exit 1
fi
