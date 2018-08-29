# Cluster terraform configuration

Check `main.tf` and `terraform.tfvars` and replace variables accordingly.

Ensure that you have created states s3 bucket beforehand and imported it later.
```
aws s3 mb s3://myterraform-states --region eu-central-1
terraform init
terraform import aws_s3_bucket.terraform_states myterraform-states
```

Please check https://www.terraform.io/docs/backends/index.html why backends are needed.


Please create vpc first and wait for network gateway to be ready, it's needed for ASG instances provisioning (package installation from internet).

```
terraform init
terraform apply -target module.vpc
terraform apply
```

Jenkins is configured using https://github.com/odavid/my-bloody-jenkins

Jenkins admin password is stored as plain text in variables just for example. Please make it secret.


To access resources please follow below. Replace `<ec2_bastion_public_ip>` with terraform output.
If you don't have Google Chrome installed, configure your favorite browser for socks5 proxy to localhost on port `1080`

```
ssh -f -D 1080 -T -l ec2-user -p 22 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no <ec2_bastion_public_ip> tail -f /dev/null
google-chrome --user-data-dir=/tmp/new --proxy-server="socks5://localhost:1080"
```

Browse http://jenkins.example.local
User is `admin`, password is `aws-berlin-2018`
