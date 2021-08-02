# Azure Provider with Terraform (Linux VM)
**This is an `experimental` repository to familiarize myself with Terraform/Azure**.

## TL;DR
```
## copy terraform.tfvars.tmpl to terraform.tfvars
$ terraform init
$ terraform apply

## Dry run
$ terraform plan

## Delete all resources
$ terraform destroy
```

## Technology used
- on local
  - Ubuntu 20.04.2 LTS
  - Terraform v1.0.0
  - azure-cli 2.61.0


### Tips
- How to switch tf version with tfenv
```
## Before switching
$ tfenv list
* 0.15.4 (set by /home/gkz/.tfenv/version)
  0.12.28
  0.12.5

## How far can you upgrade
$ tfenv list-remote | grep -E "^1.0"
1.0.0

## Install v1.0.0
$ tfenv install 1.0.0

## Check if you were able to upgrade
$ tfenv list
* 1.0.0 (set by $HOME/.tfenv/version)
  0.15.4
  0.12.28
  0.12.5
```

- Install az command, azure-cli
```
$ curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
$ az login
$ az account show | jq -r '. | {environmentName: .environmentName, name: .name}'{
  "environmentName": "AzureCloud",
  "name": "Azure for Students"
}
```
Ref: [Install the Azure CLI for Linux manually | Microsoft Docs](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)

- Display images in Azure

```
$ az vm image list -l eastus -p Canonical -f UbuntuServer --all | \
> jq -c 'sort_by(.sku) | reverse | limit(10; .[] | select(.sku|match(".*LTS.*")) | {sku: .sku, version: .version})'
{"sku":"18.04-LTS","version":"18.04.202107200"}
{"sku":"18.04-LTS","version":"18.04.202106220"}
{"sku":"18.04-LTS","version":"18.04.202106040"}
{"sku":"18.04-LTS","version":"18.04.202105120"}
{"sku":"18.04-LTS","version":"18.04.202105080"}
{"sku":"18.04-LTS","version":"18.04.202105010"}
{"sku":"18.04-LTS","version":"18.04.202104150"}
{"sku":"18.04-LTS","version":"18.04.202103250"}
{"sku":"18.04-LTS","version":"18.04.202103151"}
{"sku":"18.04-LTS","version":"18.04.202102240"}
$
```
Ref: [[Azure]TerraformでLinux VMをデプロイするイメージのバージョンをjqでイイカンジに調べる方法](https://zenn.dev/gkz/articles/azure-provider-terraform-jq) 

## License
Copyright (c) 2021 [gkz](https://gkz.mit-license.org/2021)

Licensed under the [MIT license](LICENSE).

Unless attributed otherwise, everything is under the MIT licence. Some stuff is not from me, and without attribution, and I no longer remember where I got it from. I apologize for that.
