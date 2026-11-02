# AWS Lambda Web Function Runtime Example

Three-page Next.js SSR blog on Lambda Web Functions in `us-east-1`.

Requires Git, Go, Terraform, Node.js 24, pnpm, and configured AWS credentials.
The state bucket in `backend.tf` must already exist.

## Run locally

```bash
cd app
pnpm install --frozen-lockfile
pnpm dev
```

Open http://localhost:3000. Posts are in `app/content/`.

## Deploy

From the repository root (the script builds a pinned development AWS provider):

```bash
bash scripts/build-provider.sh
export TF_CLI_CONFIG_FILE="$PWD/.terraform/provider-dev.tfrc"
terraform init
terraform apply
terraform output -raw app_url
```

Keep `TF_CLI_CONFIG_FILE` set for Terraform commands. On a fresh machine with
existing state, use `terraform apply -replace=terraform_data.build`.

## Clean up

```bash
terraform destroy
```
