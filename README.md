# Terraform AWS

Repository to present a project created using Terraform with the goal to automate resource creation using the AWS platform

* **Dependencies**
  - Terraform v0.14.3
  - AWS Service Account (at the least EC2 and IAM Permissions)

* **How Authenticate on AWS Provider**
  -  1st Option: Export environment variable:

     ```bash
     export AWS_ACCESS_KEY_ID={key_id}
     export AWS_SECRET_ACCESS_KEY={secret_key}
     ```

  - 2nd Option: Authenticate using awscli
    ```bash
    aws configure
    #fill the fields with access key id and secret access key
    ```

> To install _awscli_ see: [https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

## Project AWS

Project to automate the EC2 instance creation under ALB (Application Load Balancer) and configuration a Autoscaling Group. 

* **Resources Provided**
  - **Role**: IAM Role with S3 Access used as instance profile
  - **Network**: 
    - A VPC with two publics subnets and two private subnets 
    - A Security Group to allow ingress request on port 80 and all egress reqest
  - **EC2**: Debian instance using a private subnet and provided apache2 by cloud init script.
  - **Loadbalancer**: Provided a ALB and attached the EC2 Instance.
  - **Autoscaling**: 
    - Create a launch configuration equal the EC2 Configuration 
    - Configuration the autoscaling group with minimum size of 1 and maximum size of 3 and attached on ALB
    - Configuration the life cycle policy with the follow metrics:
      - Scale Up: CPU > 80%
      - Scale Down: CPU < 60% 

### Execution

To execute this project and provide the resources is recommended follow the steps below:

* Create the environment 

  ```bash
  git clone 
  cd project_aws
  terraform init #Initialize the Terraform and providers plugins
  terraform validate #Check any modification syntax
  terraform plan #Plan the execution 
  terraform apply #Apply and configure the project resources
  ```

> You can modify the variables configurations using the command: `terraform apply -var key1=value -var key2=value ... -var keyN=value`

* Delete the environment

To finalize and delete all resource, execute the follow command:

  ```bash
  terraform destroy
  ```

### INPUTS

See the below table to know about all options defined on variables.tf file

Name | Description | Type | Default | 
:----: | ----------- | :----: | :-------: |
region | Set Provide Region | string | us-east-1
s3_role_name | S3 Access role name | string | s3-access-role
s3_role_file_path | S3 Role file path (e.g /path/role.json) | string | files/s3_role.json
s3_policy_name | S3 Access Policy name | string | s3-access-policy
s3_policy_file_path | S3 Policy file path (e.g /path/policy.json) | string | files/s3_policy.json
vpc_name | VPC Name | string | vpc-web
vpc_network | Set a Network to a VPC (e.g 192.168.0.0/16) | string | 192.168.0.0/16
vpc_enable_dns_hostnames | Enable DNS Hostnames (true/false) | bool | true
igw_name | Internet Gateway Name | string | igw-web 
route_igw_name | Internet Gateway Route Name | string | route-igw
route_default_cidr | Define the CIDR Block to the Internet Gateway and NAT Gateway as default route | string | 0.0.0.0/0
private_subnet | Define the Private subnet configurations | map(any) | see [variables.tf](./project_aws/variable.tf#L70) line 70
public_subnet | Define the Public subnet configurations | map(any) | see [variables.tf](./project_aws/variable.tf#L85) line 85
natgw_name | NAT Gateway Name | string | nat-gw
route_natgw_name | NAT Gateway Route Name | string | route-natgw
sg_name | Security Group Name | string | fw-web |
image_owners | List with AMI Owners (default - Debian ID) | list(string) | ["136693071363"]
ami_most_recent | AMI Most Recent (true/false) | bool | true
filter_ami_fieldname | Field name to using on AMI Filter | string | name
filter_ami_value | Value list to filter AMI | list(string) | ["debian-10-amd64-\*"]
instance_profile_name | IAM Instance profile Name | string | s3_access_profile-ec2
ec2_name | EC2 Name | string | instance-web
ec2_type | EC2 Type | string | t2.micro 
userdata_file_path | User data file path (e.g /path/script.sh) | string | files/apache.sh
loadbalancer_name | Load Balancer Name | string | lb-web 
loadbalancer_type | Load Balancer Type | string | application
loadbalancer_targetgroup_name | LB Target Group Name | string | lb-tg-web 
loadbalancer_port  |Load Balancer port to check instances | number | 80
loadbalancer_protocol | Load Balancer protocol to check instances | string | HTTP
lb_action_type | LB - Default Action type | string | forward
launch_configuration_name | Launch Configuration Name | string | lc-web | 
autoscaling_policy | Autoscaling policy configurations | map(any) | see [variables.tf](./project_aws/variable.tf#L224) line 224
autoscaling_alarm | Autoscaling alarm configurations | map(any) | see [variables.tf](./project_aws/variable.tf#241) line 241

### OUTPUTS 

See the table below to know all outputs defined on outputs.tf file

Name | Description 
---- | -----------
loadbalancer_dns | Show the loadbalancer DNS

## References

* [Terraform AWS Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [VPC with public and private subnets (NAT)](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
* [Debian AMI ID](https://wiki.debian.org/Cloud/AmazonEC2Image/Marketplace)

