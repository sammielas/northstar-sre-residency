# Terraform state bootstrap

The backend resources are disabled by default.

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Keep `enable_state_backend_creation = false` until the Region and names are approved.
