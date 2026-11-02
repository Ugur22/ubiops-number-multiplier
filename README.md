# UbiOps number multiplier

Terraform-managed UbiOps deployment (in an existing project) that multiplies a number (`input` -> `output = input * factor`; the factor is set in `deployment_package/deployment.py`).

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
- Token role is `project-admin`: `project-editor` can create but not delete versions, so replacements and `terraform destroy` returned 403.
- Provider auth via env vars (`UBIOPS_API_TOKEN`, `UBIOPS_BASE_URL`), never in code or in a committed file.
- Version is replaced when the code changes: it only references the zip by path, so Terraform saw no diff. A `terraform_data` resource tracks the zip hash and `replace_triggered_by` uses it.
- Input/output are typed `double` fields so the API validates requests.
- Factor is read from an env var (default 4) so it can later be managed in Terraform without touching the logic.
- `maximum_instances = 1`: the provider default (5) exceeds the subscription limit (API returns 400).
- `environment` uses the full name `ubiops-ubuntu24-04-python3-13`: the short alias is normalized by the API and causes an inconsistent-result error.
- `terraform.tfvars` and state are gitignored: state can contain sensitive values.
