# Homework10: Multi-OS EC2 Configuration with Ansible

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

### My Screenshots:

**1 Make sure the AWS CLI credential:**

<img width="767" alt="01" src="https://github.com/user-attachments/assets/abded92b-fa74-4804-acbe-7d441c468505" />


**2 Generated AMI:**

<img width="1171" alt="02" src="https://github.com/user-attachments/assets/64ae1c5f-662e-4a92-897c-772b850e0f1f" />


**3 Init terreform:**

<img width="740" alt="03" src="https://github.com/user-attachments/assets/c7829a83-4d4b-4dd1-8090-696eb6dd639b" />


**4 Create 1 bastion host in the public subnet and 6 private EC2 instances**

<img width="853" alt="04" src="https://github.com/user-attachments/assets/252a6890-7ae3-4c0b-bf1a-85c82ff33dc5" />


**5 EC2 instance dashboard:**

<img width="1195" alt="05" src="https://github.com/user-attachments/assets/a6b5b634-2fdb-4811-9e7a-13f931b3db16" />


**6 SSH login to the bastion:**

<img width="676" alt="06" src="https://github.com/user-attachments/assets/81809d9d-5d3b-41ca-bcb6-736593e788fb" />


**7 Check Amazon Linux:**

<img width="401" alt="07" src="https://github.com/user-attachments/assets/9637ec95-2364-4459-afa0-801277d925a7" />


**8 Check Docker:**

<img width="513" alt="08" src="https://github.com/user-attachments/assets/329f0146-58da-4065-8de3-b0d39b6b0c01" />


**9 Check one of the private EC2 ip address:**

<img width="1151" alt="09" src="https://github.com/user-attachments/assets/475d0d86-81dc-4206-8ea6-642f4fa230a6" />


**10 Test whether can connect to this private EC2 instance:**

<img width="526" alt="10" src="https://github.com/user-attachments/assets/8c18edf6-14df-4dc5-8025-34064ce0c824" />


### Completed!!
