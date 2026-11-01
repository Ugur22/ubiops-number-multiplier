data "archive_file" "package" {
  type        = "zip"
  source_dir  = "${path.module}/deployment_package"
  output_path = "${path.module}/build/multiplier.zip"
}

# The version only references the zip by path, so Terraform can't see code changes.
# Tracking the package hash here lets us force a new version when the code changes.
resource "terraform_data" "package_hash" {
  input = data.archive_file.package.output_sha256
}

resource "ubiops_deployment" "multiplier" {
  project_name = var.project_name
  name         = "number-multiplier"
  description  = "Multiplies a number by a fixed factor (set in deployment.py)."
  input_type   = "structured"
  output_type  = "structured"

  input_fields  = [{ name = "input", data_type = "double" }]
  output_fields = [{ name = "output", data_type = "double" }]
}

resource "ubiops_deployment_version" "v1" {
  project_name             = var.project_name
  deployment_name          = ubiops_deployment.multiplier.name
  version                  = var.version_name
  environment              = var.environment
  instance_type_group_name = var.instance_type_group_name
  source_file              = data.archive_file.package.output_path

  # Provider default is 5; the current subscription caps instances at 1.
  maximum_instances = 1

  lifecycle {
    replace_triggered_by = [terraform_data.package_hash]
  }
}
