data "archive_file" "package" {
  type        = "zip"
  source_dir  = "${path.module}/deployment_package"
  output_path = "${path.module}/build/multiplier.zip"
}

resource "ubiops_deployment" "multiplier" {
  project_name = var.project_name
  name         = "number-multiplier"
  description  = "Multiplies a number by a fixed factor (2 by default)."
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
}
