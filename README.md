# Homework10: Multi-OS EC2 Configuration with Ansible

##  Description of the Project

This project automates the provisioning of AWS infrastructure using Terraform, creates a custom AMI using Packer, and configures EC2 instances with Ansible.

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

**Expected Outputs**

ubuntu_private_ips = ["10.0.2.xxx", ...]
amazon_private_ips = ["10.0.2.xxx", ...]
controller_private_ip = "10.0.2.xxx"

<img width="456" alt="Screenshot 2025-03-30 at 22 27 16" src="https://github.com/user-attachments/assets/49de312a-9b25-4d0a-8408-3810931a2281" />


**modify inventory.ini file**
modify the ubuntu and amazon private ip into inventory.ini, change like this:
[ubuntu]
10.0.2.80
10.0.2.22
10.0.2.50

[amazon]
10.0.2.86
10.0.2.141
10.0.2.190


Copy SSH key and Ansible files

First, log in to EC2 instance dashboard, to check the BastionHost OS typr, if Amazon/linux, using ec2-user, if Ubuntu, use ubuntu

#### 1. Copy key and Ansible folder to Bastion Host (replace <3.81.133.133>):

```bash
scp -i ~/.ssh/packer_rsa ~/.ssh/packer_rsa ec2-user@3.81.133.133:~
```
or Ubuntu OS:
```bash
scp -i ~/.ssh/packer_rsa ~/.ssh/packer_rsa ubuntu@3.81.133.133:~
```

Under root folder, scp ansible folder (replace <3.81.133.133> with your actual public Bastion ip address):

```bash
scp -i ~/.ssh/packer_rsa -r ansible ec2-user@3.81.133.133:~
```
or
```bash
scp -i ~/.ssh/packer_rsa -r ansible ubuntu@3.81.133.133:~
```

#### 2. SSH into Bastion:

```bash
ssh -i ~/.ssh/packer_rsa ec2-user@3.81.133.133
```
or

```bash
ssh -i ~/.ssh/packer_rsa ubuntu@3.81.133.133
```

#### 3. From Bastion, copy to Ansible Controller (replace the CONTROLLER_PRIVATE_IP <10.0.2.14> ):
(Check the controller's private ip address in EC2 instance dashboard)

```bash
scp -i ~/packer_rsa ~/packer_rsa ec2-user@10.0.2.14:~
scp -i ~/packer_rsa -r ~/ansible ec2-user@10.0.2.14:~
```

or

```bash
scp -i ~/packer_rsa ~/packer_rsa ubuntu@10.0.2.14:~
scp -i ~/packer_rsa -r ~/ansible ubuntu@10.0.2.14:~
```

Then, set permissions:
```bash
chmod 600 ~/packer_rsa
```

#### 4. Run Ansible Playbook

SSH into Controller:
```bash
ssh -i ~/packer_rsa ubuntu@10.0.2.14
```

Once you SSH into the controller EC2 (Ubuntu in the private subnet), run the following to install Ansible:
```bash
sudo apt update
sudo apt install -y ansible
ansible --version
```

Set permissions:
```bash
chmod 600 ~/packer_rsa
```

Manually SSH log in to each private machine:
```bash
ssh -i ~/packer_rsa ubuntu@10.0.2.80
exit
```

```bash
ssh -i ~/packer_rsa ubuntu@10.0.2.22
exit
```

```bash
ssh -i ~/packer_rsa ubuntu@10.0.2.50
exit
```

```bash
ssh -i ~/packer_rsa ec2-user@10.0.2.86
exit
```

```bash
ssh -i ~/packer_rsa ec2-user@10.0.2.141
exit
```

```bash
ssh -i ~/packer_rsa ec2-user@10.0.2.190
exit
```

Run the Playbook:
```bash
cd ~/ansible
ansible-playbook -i inventory.ini playbook.yml
```

**Expected Outputs**

<img width="852" alt="Screenshot 2025-03-30 at 23 45 38" src="https://github.com/user-attachments/assets/40a8a88b-a026-4c87-b10e-d644cce90066" />


