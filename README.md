# End to end ML

## Setup environment

```bash
conda create --name end_to_end_ml python=3.9 -y
conda activate end_to_end_ml
```

## Terraform commands

```bash
gcloud storage buckets create gs://end-to-end-ml-terraform-state --project=XXXXXX --location=EUROPE-WEST1
```

```bash
terraform plan -var-file=vars.tfvars
terraform apply -var-file=vars.tfvars
terraform destroy -var-file=vars.tfvars
```
