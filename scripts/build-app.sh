#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
build_dir="$(pwd)/.terraform/lambda-build"
mkdir -p "$build_dir"
rm -rf "$build_dir/source" "$build_dir/package" "$build_dir/runtime"
mkdir -p "$build_dir/source" "$build_dir/package" "$build_dir/runtime"
tar --exclude='./node_modules' --exclude='./.next' --exclude='./.git' \
  --exclude='*.tsbuildinfo' -C app -cf - . | tar -C "$build_dir/source" -xf -

(
  cd "$build_dir/source"
  pnpm install --frozen-lockfile
  NEXT_TELEMETRY_DISABLED=1 pnpm build
)

cp -a "$build_dir/source/.next/standalone/." "$build_dir/package/"

# Install deployment dependencies for Lambda's Linux Arm64 runtime.
cp "$build_dir/source/package.json" "$build_dir/source/pnpm-lock.yaml" "$build_dir/runtime/"
(
  cd "$build_dir/runtime"
  pnpm install --prod --frozen-lockfile --os=linux --cpu=arm64 --libc=glibc
)
rm -rf "$build_dir/package/node_modules"
cp -a "$build_dir/runtime/node_modules" "$build_dir/package/node_modules"

mkdir -p "$build_dir/package/.next/static"
cp -a "$build_dir/source/.next/static/." "$build_dir/package/.next/static/"
if [ -d "$build_dir/source/public" ]; then
  mkdir -p "$build_dir/package/public"
  cp -a "$build_dir/source/public/." "$build_dir/package/public/"
fi

cat > "$build_dir/package/lambda-entrypoint.cjs" <<'JS'
const endpoint = process.env.AWS_LAMBDA_HTTP_ENDPOINT;
if (!endpoint) throw new Error('AWS_LAMBDA_HTTP_ENDPOINT is required');
const separator = endpoint.lastIndexOf(':');
process.env.HOSTNAME = endpoint.slice(0, separator);
process.env.PORT = endpoint.slice(separator + 1);
process.env.NODE_ENV = 'production';
require('./server.js');
JS
