# CS686 Packer & Terraform Project

##  Description of the Project

- Create a custom Amazon Linux 2 AMI with Docker installed using **Packer**
- Deploy a secure AWS VPC infrastructure using **Terraform**, with:
  - Public/private subnets
  - Bastion Host for SSH access
  - 6 EC2 instances using the custom AMI

---

##  Instructions on How to Run

###  1. Configure AWS CLI (Academy credentials)

Edit your `~/.aws/credentials` file:
```
[default] aws_access_key_id = <YOUR_AWS_ACCESS_KEY_ID> aws_secret_access_key = <YOUR_AWS_SECRET_ACCESS_KEY> aws_session_token = <YOUR_AWS_SESSION_TOKEN>
```

Remember to check your aws region, my region is set as: **us-east-1**

Then verify with:

```bash
aws sts get-caller-identity
```

###  2. Generate SSH Key and Import to AWS

This key is used by Packer to SSH into the temporary EC2 during AMI creation.

#### Step 1: Create a passwordless SSH key pair (if not already created)

```bash
ssh-keygen -t rsa -b 2048 -f ~/.ssh/packer_rsa -N ""
```

#### Step 2: Import the public key to AWS

```bash
aws ec2 import-key-pair \
  --key-name "packer-key" \
  --public-key-material fileb://~/.ssh/packer_rsa.pub
```

### 3. Build the AMI with Packer

```bash
cd packer-ami
packer init .
packer build .
```

After build, you'll see an AMI ID like:
```bash
us-east-1: ami-0a443a001ef93bfa9
```

Copy this AMI ID for the next step.

### 4. Deploy Infrastructure with Terraform

Edit terraform.tfvars to include:

```bash
ami_id = "ami-0a443a001ef93bfa9"  # copy the ami just generated
my_ip  = "YOUR_PUBLIC_IP/32"  # You can find your public IP from: https://whatismyipaddress.com
```
You can find your public IP from: https://whatismyipaddress.com


Init terraform:

```bash
cd terraform-vpc  # cd to terraform-vpc from the root folder
terraform init
```

Then run:

```bash
terraform apply
```

### Expected Outputs

Terraform will output:
- Bastion Host Public IP
- 6 Private EC2 Instance IDs

Example:

```bash
bastion_public_ip = "54.198.xxx.xxx"
private_instance_ids = [
  "i-xxxxxxxxxxxxxxxxx",
  ...
]
```

SSH Access Verification

```bash
ssh -i ~/.ssh/packer_rsa ec2-user@<bastion_public_ip>
```

Once inside, first start docker manually:

```bash
sudo service docker start
```

Then, verify:
```bash
cat /etc/os-release     # → Amazon Linux 2
docker --version        # → Docker installed
docker ps               # → Should show no error
```

Then, test a private ec2 (input the ip add of that private ec2)
```bash
ping 10.0.2.xx          # → Ping private EC2
```

Don't forget to exit

```bash
exit
```

### This completes the assignment and fulfills all requirements
