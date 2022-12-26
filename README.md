# SutomHistory
Daemon to daily parse website referencing daily solution for the Sutom game

# How to run
Instantiate a VM on Oracle Cloud by using the terraform script in oci directory
Then this terraform will instentiate a VM using the cloud Init cloud-init-oracle-linux.yaml
This one will directly run the docker commands with the right parameters

terraform destroy; terraform plan; terraform apply
