# AVI Controller Deployment on GCP Terraform module
This Terraform module creates and configures an AVI (NSX Advanced Load-Balancer) Controller on GCP

## Module Functions
The module is meant to be modular and can create all or none of the prerequiste resources needed for the AVI GCP Deployment including:
* VPC and Subnet for the Controller (optional with create_networking variable)
* IAM Roles and Role Bindings for supplied Service Account (optional with create_iam variable)
* GCP Compute Image from the provided bucket controller file
* Firewall Rules for AVI Controller and SE communication
* GCP Compute Instance using the Controller Compute Image

During the creation of the Controller instance the following initialization steps are performed:
* Change default password to user specified password
* Copy Ansible playbook to controller using the assigned public IP
* Run Ansible playbook to configure initial settings and GCP Full Access Cloud 

Optionally the following Avi configurations can be created:
* Avi IPAM Profile (configure_ipam_profile variable)
* Avi DNS Profile (configure_dns_profile variable)
* DNS Virtual Service (configure_dns_vs variable)

# Environment Requirements

## Google Cloud Platform
The following are GCP prerequisites for running this module:
* Service Account created for the Avi Controller
* Projects identified for the Controller, Network, Service Engines, Storage, and Backend Servers. By default this be the a single project as set by the "project" variable. Optionally the "network_project", "service_engine_project", "storage_project", and "server_project" variables can be set to use a different project than the project the Controller will be deployed to. 
* If more than 1 project will be used "Disable Cross-Project Service Account Usage" organizational policy must be set to "Not enforced" and the the Service Account must be added to those additional projects. 

## Google Provider
For authenticating to GCP you must leverage either the "GOOGLE_APPLICATION_CREDENTIALS={{path_to_service_account_key}}" environment variable or use "gcloud auth application-default login"
## Controller Image
The AVI Controller image for GCP should be uploaded to a GCP Cloud Storage bucket before running this module with the path specified in the controller-image-gs-path variable. This can be done with the following gsutil commands:

```bash
gsutil mb <bucket>
gsutil -m cp ./gcp_controller-<avi-version>.tar.gz  gs://<bucket>/
```
## Host OS 
The following packages must be installed on the host operating system:
* curl 

# Usage
```hcl
terraform {
  backend "local" {
  }
}
module "avi-controller-gcp" {
  source  = "slarimore02/avi-controller-gcp/gcp"
  version = "1.0.x"

  region = "us-west1"
  create_networking = "true"
  create_iam = "false"
  controller_default_password = "Value Redacted and available within the VMware Customer Portal"
  avi_version = "20.1.3"
  service_account_email = "<sa-account>@<project>.iam.gserviceaccount.com"
  controller_image_gs_path = "<bucket>/gcp_controller-20.1.3-9085.tar.gz"
  controller_password = "password"
  name_prefix = "avi"
  project = "gcp-project"
  vpc_network_name = "avi-vpc-network"
}
output "controller_address" { 
  value = module.avi_controller_gcp.controller_address
} 
```
## GSLB Deployment Example
```hcl
terraform {
  backend "local" {
  }
}
module "avi_controller_east" {
  source  = "slarimore02/avi-controller-gcp/gcp"
  version = "1.0.x"

  region = "us-east1"
  create_networking = "false"
  custom_vpc_name             = "vpc"
  custom_subnetwork_name      = "subnet-east-1"
  create_iam = "false"
  avi_version = "20.1.5"
  controller_public_address = "true"
  service_account_email = "<email>@<account>.iam.gserviceaccount.com"
  controller_ha = "true"
  controller_default_password = "<default-password>"
  controller_image_gs_path = "<bucket>/gcp_controller-20.1.5.tar.gz"
  controller_password = "<new-password>"
  name_prefix = "east1"
  project = "<project>"
  configure_ipam_profile          = "true"
  ipam_network                    = "192.168.252.0/24"
  ipam_network_range              = ["192.168.252.10", "192.168.252.100"]
  configure_dns_profile           = "true"
  dns_service_domain              = "east.domain"
  configure_dns_vs                = "true"
}
module "avi_controller_west" {
  source  = "slarimore02/avi-controller-gcp/gcp"
  version = "1.0.x"

  region = "us-west1"
  create_networking = "false"
  custom_vpc_name             = "vpc"
  custom_subnetwork_name      = "subnet-west-1"
  create_iam = "false"
  avi_version = "20.1.5"
  controller_public_address = "true"
  service_account_email = "<email>@<project>.iam.gserviceaccount.com"
  controller_ha = "true"
  controller_default_password = "<default-password>"
  controller_image_gs_path = "<bucket>/gcp_controller-20.1.5.tar.gz"
  controller_password = "<new-password>"
  name_prefix = "west1"
  project = "<project>"
  configure_ipam_profile          = "true"
  ipam_network                    = "192.168.251.0/24"
  ipam_network_range              = ["192.168.251.10", "192.168.251.100"]
  configure_dns_profile           = "true"
  dns_service_domain              = "west.domain"
  configure_dns_vs                = "true"
  configure_gslb                  = "true"
  gslb_site_name                  = "West1"
  gslb_domains                    = ["gslb.domain"]
  configure_gslb_additional_sites = "true"
  additional_gslb_sites           = [{name = "East1", ip_address = module.avi_controller_east.controllers[0].private_ip_address , dns_vs_name = "DNS-VS"}]
}
output "west_controller_ip" { 
  value = module.avi_controller_west.controllers
}
output "east_controller_ip" { 
  value = module.avi_controller_east.controllers
}
```
## Controller Sizing
The controller_size variable can be used to determine the vCPU and Memory resources allocated to the Avi Controller. There are 3 available sizes for the Controller as documented below:

| Size | vCPU Cores | Memory (GB)|
|------|-----------|--------|
| small | 8 | 24 |
| medium | 16 | 32 |
| large | 24 | 48 |

Additional resources on sizing the Avi Controller:

https://avinetworks.com/docs/latest/avi-controller-sizing/
https://avinetworks.com/docs/latest/system-limits/


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.6 |
| google | ~> 3.58.0 |
| null | 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.58.0 |
| null | 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_gslb\_sites | The Names and IP addresses of the GSLB Sites that will be configured. | `list(object({ name = string, ip_address = string, dns_vs_name = string }))` | <pre>[<br>  {<br>    "dns_vs_name": "",<br>    "ip_address": "",<br>    "name": ""<br>  }<br>]</pre> | no |
| avi\_subnet | The CIDR that will be used for creating a subnet in the Avi VPC | `string` | `"10.255.1.0/24"` | no |
| avi\_version | The version of Avi that will be deployed | `string` | n/a | yes |
| boot\_disk\_size | The boot disk size for the Avi controller | `number` | `128` | no |
| configure\_dns\_profile | Configure Avi DNS Profile for DNS Record Creation for Virtual Services. If set to true the dns\_service\_domain variable must also be set | `bool` | `"false"` | no |
| configure\_dns\_vs | Create DNS Virtual Service. The configure\_dns\_profile and configure\_ipam\_profile variables must be set to true and their associated configuration variables must also be set | `bool` | `"false"` | no |
| configure\_firewall\_se\_data | Configure Firewall rules for SE dataplane traffic. If set the firewall\_se\_data\_rules and firewall\_se\_data\_source\_range must be set | `bool` | `"false"` | no |
| configure\_gslb | Configure GSLB. The gslb\_site\_name, gslb\_domains, and configure\_dns\_vs variables must also be set. Optionally the additional\_gslb\_sites variable can be used to add active GSLB sites | `bool` | `"false"` | no |
| configure\_gslb\_additional\_sites | Configure Additional GSLB Sites. The additional\_gslb\_sites, gslb\_site\_name, gslb\_domains, and configure\_dns\_vs variables must also be set. Optionally the additional\_gslb\_sites variable can be used to add active GSLB sites | `bool` | `"false"` | no |
| configure\_ipam\_profile | Configure Avi IPAM Profile for Virtual Service Address Allocation. If set to true the virtualservice\_network variable must also be set | `bool` | `"false"` | no |
| controller\_default\_password | This is the default password for the Avi controller image and can be found in the image download page. | `string` | n/a | yes |
| controller\_ha | If true a HA controller cluster is deployed and configured | `bool` | `"false"` | no |
| controller\_image\_gs\_path | The Google Storage path to the GCP Avi Controller tar.gz image file using the bucket/filename syntax | `string` | n/a | yes |
| controller\_password | The password that will be used authenticating with the Avi Controller. This password be a minimum of 8 characters and contain at least one each of uppercase, lowercase, numbers, and special characters | `string` | n/a | yes |
| controller\_public\_address | This variable controls if the Controller has a Public IP Address. When set to false the Ansible provisioner will connect to the private IP of the Controller. | `bool` | `"false"` | no |
| controller\_size | This value determines the number of vCPUs and memory allocated for the Avi Controller. Possible values are small, medium, or large. | `string` | `"small"` | no |
| create\_cloud\_router | This variable is used to create a GCP Cloud Router when both the create\_networking variable = true and the vip\_allocation\_strategy = ILB | `bool` | `"false"` | no |
| create\_iam | Create IAM Roles and Role Bindings necessary for the Avi GCP Full Access Cloud. If not set the Roles and permissions in this document must be associated with the controller service account - https://Avinetworks.com/docs/latest/gcp-full-access-roles-and-permissions/ | `bool` | `"false"` | no |
| create\_networking | This variable controls the VPC and subnet creation for the Avi Controller. When set to false the custom\_vpc\_name and custom\_subnetwork\_name must be set. | `bool` | `"true"` | no |
| custom\_machine\_type | This value overides the machine type used for the Avi Controller | `string` | `""` | no |
| custom\_subnetwork\_name | This field can be used to specify an existing VPC subnetwork for the controller and SEs. The create\_networking variable must also be set to false for this network to be used. | `string` | `null` | no |
| custom\_vpc\_name | This field can be used to specify an existing VPC for the controller and SEs. The create\_networking variable must also be set to false for this network to be used. | `string` | `null` | no |
| dns\_search\_domain | The optional DNS search domain that will be used by the controller | `string` | `""` | no |
| dns\_servers | The optional DNS servers that will be used for local DNS resolution by the controller. Example ["8.8.4.4", "8.8.8.8"] | `list(string)` | `null` | no |
| dns\_service\_domain | The DNS Domain that will be available for Virtual Services. Avi will be the Authorative Nameserver for this domain and NS records may need to be created pointing to the Avi Service Engine addresses. An example is demo.Avi.com | `string` | `""` | no |
| dns\_vs\_settings | The DNS Virtual Service settings. With the auto\_allocate\_ip option is set to "true" the VS IP address will be allocated via an IPAM profile. Example:{ auto\_allocate\_ip = "true", auto\_allocate\_public\_ip = "true", vs\_ip = "", network\_name = "network-192.168.20.0/24", network = "192.168.20.0/24" } | `object({ auto_allocate_ip = bool, auto_allocate_public_ip = bool, vs_ip = string, network = string })` | `null` | no |
| email\_config | The Email settings that will be used for sending password reset information or for trigged alerts. The default setting will send emails directly from the Avi Controller | `object({ smtp_type = string, from_email = string, mail_server_name = string, mail_server_port = string, auth_username = string, auth_password = string })` | <pre>{<br>  "auth_password": "",<br>  "auth_username": "",<br>  "from_email": "admin@avicontroller.net",<br>  "mail_server_name": "localhost",<br>  "mail_server_port": "25",<br>  "smtp_type": "SMTP_LOCAL_HOST"<br>}</pre> | no |
| firewall\_controller\_allow\_source\_range | The IP range allowed to connect to the Avi Controller. Access from all IP ranges will be allowed by default | `string` | `"0.0.0.0/0"` | no |
| firewall\_se\_data\_rules | The ports allowed for Virtual Services hosted on Services Engines. The configure\_firewall\_se\_data variable must be set to true for this rule to be created | `list(object({ protocol = string, port = list(string) }))` | <pre>[<br>  {<br>    "port": [<br>      "443",<br>      "53"<br>    ],<br>    "protocol": "tcp"<br>  },<br>  {<br>    "port": [<br>      "53"<br>    ],<br>    "protocol": "udp"<br>  }<br>]</pre> | no |
| firewall\_se\_data\_source\_range | The IP range allowed to access Virtual Services hosted on Service Engines. The configure\_firewall\_se\_data and firewall\_se\_data\_rules variables must also be set | `string` | `"0.0.0.0/0"` | no |
| gslb\_domains | A list of GSLB domains that will be configured | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| gslb\_site\_name | The name of the GSLB site the deployed Controller(s) will be a member of. | `string` | `""` | no |
| ipam\_networks | This variable configures the IPAM network(s). Example: { network = "192.168.20.0/24" , static\_pool = ["192.168.1.10","192.168.1.30"]} | `list(object({ network = string, static_pool = list(string) }))` | <pre>[<br>  {<br>    "network": "",<br>    "static_pool": [<br>      ""<br>    ]<br>  }<br>]</pre> | no |
| name\_prefix | This prefix is appended to the names of the Controller and SEs | `string` | n/a | yes |
| network\_project | The GCP Network project that the Controller and SEs will use. If not set the project variable will be used | `string` | `""` | no |
| ntp\_servers | The NTP Servers that the Avi Controllers will use. The server should be a valid IP address (v4 or v6) or a DNS name. Valid options for type are V4, DNS, or V6 | `list(object({ addr = string, type = string }))` | <pre>[<br>  {<br>    "addr": "0.us.pool.ntp.org",<br>    "type": "DNS"<br>  },<br>  {<br>    "addr": "1.us.pool.ntp.org",<br>    "type": "DNS"<br>  },<br>  {<br>    "addr": "2.us.pool.ntp.org",<br>    "type": "DNS"<br>  },<br>  {<br>    "addr": "3.us.pool.ntp.org",<br>    "type": "DNS"<br>  }<br>]</pre> | no |
| project | The project used for the Avi Controller | `string` | n/a | yes |
| region | The Region that the Avi controller and SEs will be deployed to | `string` | n/a | yes |
| se\_ha\_mode | The HA mode of the Service Engine Group. Possible values active/active, n+m, or active/standby | `string` | `"active/active"` | no |
| se\_size | The CPU, Memory, Disk Size of the Service Engines. The default is 1 vCPU, 2 GB RAM, and a 15 GB Disk per Service Engine. Syntax ["cpu\_cores", "memory\_in\_GB", "disk\_size\_in\_GB"] | `list(string)` | <pre>[<br>  "1",<br>  "2",<br>  "15"<br>]</pre> | no |
| server\_project | The backend server GCP Project. If not set the project variable will be used | `string` | `""` | no |
| service\_account\_email | This is the service account that will be leveraged by the Avi Controller. If the create-iam variable is true then this module will create the necessary custom roles and bindings for the SA | `string` | n/a | yes |
| service\_engine\_project | The project used for Avi Service Engines. If not set the project variable will be used | `string` | `""` | no |
| storage\_project | The storage project used for the Avi Controller Image. If not set the project variable will be used | `string` | `""` | no |
| vip\_allocation\_strategy | The VIP allocation strategy for the GCP Cloud - ROUTES or ILB | `string` | `"ROUTES"` | no |

## Outputs

| Name | Description |
|------|-------------|
| controllers | The AVI Controller(s) Information |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->