# Deploy FortiGate-VM (BYOL/PAYG) HA Load Balancer Cluster on Azure in different zones with 3 ports
A Terraform script to deploy a FortiGate-VM Cluster on Azure using a load-balancer HA topology

## Introduction
This topology is only recommended for using with FOS 7.0.5 and later which supports 3 port HA setup combining HA reserved management ports and sync into the same interfaces.
* port1 - hamgmt/hasync with public IP
* port2 - public/untrust
* port3 - private/trust

This topology requires an Azure region that supports availability zones.

## Requirements

* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= 0.12.0
* Terraform Provider AzureRM >= 2.24.0
* Terraform Provider Template >= 2.2.0
* Terraform Provider Random >= 3.1.0

## Deployment overview
Terraform deploys the following components:

* Azure Virtual Network with 4 subnets - external, internal, 2x workload subnets
* 2x FortiGate-VM (BYOL/PAYG) instances with three NICs.  Each FortiGate-VM reside in different availability zones.
* Untrust interface placed in SD-WAN zone "Underlay".
* 2x firewall rules - permit outbound, and permit internal.
* 2x Ubuntu 20.04 LTS test client VMs in each workload subnet.
* Choose PAYG or BYOL in variables - if BYOL, place .lic files in subfolder "licenses" and define in variables.

![img](https://github.com/wintermute000/azure-fgt-lb-ha-crosszone-3port/blob/master/azure-fgt-lb-ha-crosszone-3port.jpg)

### If BYOL is used, then the VNET summary route will not be created in FortiOS due to the limitation of unlicensed VM only allowing 3 routes. Add the VNET summary route after licensing has finished.

For a detailed walkthrough of the operation of this topology, refer to https://github.com/fortinet/azure-templates/tree/main/FortiGate/Active-Passive-ELB-ILB

## Deployment

To deploy the FortiGate-VM to Azure:
1. Clone the repository.
2. Customize variables defined in `variables.tf` file as needed with a standard *.auto.tfvars file.
3. Initialize the providers and modules and run terraform as normal.

Outputs:

ActiveMGMTPublicIP = <Active FGT Management Public IP>
ClusterPublicIP = <Cluster Public IP>
PassiveMGMTPublicIP = <Passive FGT Management Public IP>
Password = <FGT Password>
ResourceGroup = <Resource Group>
Username = <FGT admin>


## Acknowledgements
This template was developed from the starting point of https://github.com/fortinet/fortigate-terraform-deploy/tree/main/azure/7.2/ha-port1-mgmt-crosszone-3ports

## Support
Fortinet-provided scripts in this and other GitHub projects do not fall under the regular Fortinet technical support scope and are not supported by FortiCare Support Services.
For direct issues, please refer to the [Issues](https://github.com/fortinet/fortigate-terraform-deploy/issues) tab of this GitHub project.
For other questions related to this project, contact [github@fortinet.com](mailto:github@fortinet.com).

## License
[License](https://github.com/fortinet/fortigate-terraform-deploy/blob/master/LICENSE) © Fortinet Technologies. All rights reserved.
# 
