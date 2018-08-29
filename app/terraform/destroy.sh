#!/bin/bash

terraform init
terraform plan -destroy -var 'version=0' -var 'name=iplookup' -var 'region=eu-central-1' -out destroy.plan
terraform apply destroy.plan
