# Install dependencies and create the layer ZIP

resource "terraform_data" "python_layer_deps" {
  triggers_replace = {
    requirements = filesha256("${path.module}/../lambda/layers/requirements.txt")
  }

  provisioner "local-exec" {
    command     = <<-EOT
      cd ${path.module}/../lambda/layers/ && \
      rm -rf package && \
      mkdir -p package/python && \
      pip install \
        -r requirements.txt \
        --target package/python \
        --platform manylinux2014_x86_64 \
        --implementation cp \
        --python-version ${var.python_version} \
        --only-binary=:all:
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

data "archive_file" "python_layer" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/layers/package"
  output_path = "${path.module}/../lambda/layers/layer.zip"

  depends_on = [terraform_data.python_layer_deps]
}


# Create the Lambda layer
resource "aws_lambda_layer_version" "extract_layer" {
  layer_name          = "extract-layer"
  description         = "Packages need for extract phase"
  filename            = data.archive_file.python_layer.output_path
  source_code_hash    = data.archive_file.python_layer.output_base64sha256
  compatible_runtimes = ["python3.12"]

  # Optional: compatible architectures
  compatible_architectures = ["x86_64"]
}