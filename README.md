# UbiOps number multiplier

Terraform-managed UbiOps deployment (in an existing project) that multiplies a number (`input` -> `output = input * factor`; the factor is set in `deployment_package/deployment.py`).

## Layout
- `deployment_package/deployment.py` – the code UbiOps runs
- `main.tf` – deployment (I/O schema), version (zipped package)
- `variables.tf`, `versions.tf`, `terraform.tfvars.example`

## Use
1. Create a project in the UbiOps UI.
2. In that project: Project Admin > Permissions > API tokens > Add token, with role `project-admin`.
3. Run:
```sh
export UBIOPS_API_TOKEN="Token <your token>"
export UBIOPS_BASE_URL="https://api.ubiops.com/v2.1"
cp terraform.tfvars.example terraform.tfvars   # fill project_name and instance_type_group_name
terraform init && terraform plan && terraform apply
```
Test in the UI (deployment > Create request) with `{"input": 10}`; the output is `10 * factor` (40 with the default factor of 4, set in `deployment.py`).

## Decisions
- Project is created in the UI, not Terraform: API tokens are project-scoped, so a token cannot exist before its project.
- Provider auth via env vars (`UBIOPS_API_TOKEN`, `UBIOPS_BASE_URL`), never in code or in a committed file: the `provider "ubiops" {}` block is empty and reads them from the shell.
- Input/output are typed `double` fields (structured) so the API validates requests.
- Package is zipped by `archive_file`. The version only references the zip by path, so a `terraform_data` resource tracks the zip's hash and `replace_triggered_by` replaces the version on code change (found when an edited `deployment.py` showed no diff).
- Factor is read from an env var in the code (default 4) so it can later be a Terraform-managed setting without touching the logic.
- Changing project/resource names forces replacement; always read the plan.
- Token role is `project-admin`: `project-editor` can create but not delete versions, so replacements and `terraform destroy` returned 403.
- `maximum_instances = 1`: the provider default (5) exceeds the current subscription limit; the API rejects it with a 400.
- `environment` uses the full name `ubiops-ubuntu24-04-python3-13`: the API normalizes the short alias, which made Terraform report an inconsistent result.
- Smallest instance type group (`256 MB + 0.0625 vCPU`): the workload is trivial and credits are limited.
- `terraform.tfvars` and state are gitignored: state can contain sensitive values.
