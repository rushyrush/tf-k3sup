# tf-k3sup

Deploy a k3s cluster on AWS using Terraform and k3sup.

## Requirements

Required packages:

* [terraform](https://www.terraform.io/downloads.html) >= v0.14.8
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [k3sup](https://github.com/alexellis/k3sup)
* [curl](https://curl.se/)

## Setup


Populate the `terraform.tfvars` file with required and optional variables:

* Required variables and other variables are templated within `terraform.tfvars.example`.
* More variables, information, and descriptions for other variables are available in `variables.tf`.

## Running

Initialize terraform:

```
terraform init
```

Apply the terraform module (requires interactive confirmation):

```
terraform apply
```

Set your `KUBECONFIG` file to the newly generated file:

```
export KUBECONFIG=$(terraform output -raw kube_config_path)
```

## Cleanup

```
terraform destroy --auto-approve
```

## Security

Several security groups are created to harden the terraform deployment from public access:

* `ingress_sg` - Allows full ingress from any resource within this security group.
* `ingress_client` - Allows full ingress from your client IP address (laptop, etc).
* `egress_all` - Allows full egress from any resource within this terraform module.

**Note:** You may need to disable your VPN or firewall (F5, AnyConnect, ZScaler, etc). Your client IP address is obtained from an external resource, any these programs may conflict with your obtained and presented IP address, causing this module deployment to fail.

## Region

The default region for this module is intended to be `us-gov-west-1`.

You may change this, but note that various other resources will need to be modified.

Namely, variables within the `ami` section will need to reflect a new AMI filter for your region.