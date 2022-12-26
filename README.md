# SutomHistory
Daemon to daily parse website referencing daily solution for the Sutom game

# To build the container for both intel and ARM, go to windows to use buildx
from git bash git pull latest versions, and then do:
PS C:\Users\lucch\development\LucChoubert\SutomHistory> docker buildx build --platform linux/amd64,linux/arm64 -t docker.io/lucchoubert/sutomhistory:0.1 --push .

# How to run
Instantiate a VM on Oracle Cloud by using the terraform script in oci directory
Then this terraform will instentiate a VM using the cloud Init cloud-init-oracle-linux.yaml
This one will directly run the docker commands with the right parameters

terraform destroy; terraform plan; terraform apply
