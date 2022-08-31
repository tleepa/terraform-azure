# terraform-azure

Example 2-stage Terraform deployment.

## Concept

Landing Zone consists of single VNet with two subnets, one public, one private.

Connections from the Internet are only allowed to the public subnet, port 22, from
source from IP that machine running terraform is visible (checked via [https://ipinfo.io/ip](https://ipinfo.io/ip))

Once connected to the jump host in the public subnet, you can access other (private)
VMs using their hostnames or FQDNs: `hostname.private_domain`

Resources' names:

- VM hostname: `<prefix>-<workspace>-<function>-<count_index>`
- private domain: `<prefix>-<workspace>.local`

## Usage

### Authenticate to Azure

Refer to [AzureRM provider docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure),
e.g. using [Service Principal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)
with evironment variables:

```shell
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

### Stage 1 - Landing Zone

```shell
cd lz
```

Create new workspace

```shell
terraform workspace new <name>
```

Prepare `terraform.tfvars` file, e.g.:

```ini
prefix        = "xx"
address_space = "192.168.0.0/24"
subnet_pub    = "192.168.0.0/25"
subnet_prv    = "192.168.0.128/25"
region        = "West Europe"
```

Run

```shell
terraform init
terraform plan
terraform apply
```

Note output *private_domain*.

This landing zone is meant to be more "permanent" with following costs
(as reported by [Infracost](https://www.infracost.io/)):

```text
Project: tleepa/terraform-azure/lz

 Name                               Monthly Qty  Unit    Monthly Cost 
                                                                      
 azurerm_private_dns_zone.prv_zone                                    
 └─ Hosted zone                               1  months         $0.50 
                                                                      
 OVERALL TOTAL                                                  $0.50 
──────────────────────────────────
10 cloud resources were detected:
∙ 1 was estimated
∙ 9 were free:
  ∙ 2 x azurerm_network_security_group
  ∙ 2 x azurerm_subnet
  ∙ 2 x azurerm_subnet_network_security_group_association
  ∙ 1 x azurerm_private_dns_zone_virtual_network_link
  ∙ 1 x azurerm_resource_group
  ∙ 1 x azurerm_virtual_network
```

### Stage 2 - VMs

```shell
cd ../res
```

Create new workspace

```shell
terraform workspace new <name>
```

Prepare `terraform.tfvars` file, e.g.:

```ini
win_pass     = "<password meeting Azure requirements>"
prefix       = "xx"
ssh_key_path = "<path to directory with SSH keys>"
```

Prepare SSH key for selected workspace

```shell
ssh-keygen -t rsa -b 4096 -f .<path to directory with SSH keys>/<workspace name>
```

Adjust `locals.tf` file for deployed VMs:

- *jbs* - jump hosts, deployed in public subnet
- *vms* - other VMs, deployed in private subnet

These maps have following attributes:

- `os` - mandatory:
  - *lx* for Linux, default image is Alma Linux 8.5
  - *win* for Windows, default image is Windows Server 2019
- `fnc` - mandatory - function (e.g. jb, web, db)
- `count_index` - optional -
  number appended to the VM name if creating many with same function
- `size` - optional - Azure size if other than default *Standard_B1s*

Run

```shell
terraform init
terraform plan
terraform apply
```

Outputs will show ssh command to connect to the jump box (public subnet) machines
and hostnames for all private VMs.
