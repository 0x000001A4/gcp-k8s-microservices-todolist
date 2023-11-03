#!/usr/bin/env bash

set -x

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get -y upgrade

# Install everything to be able to add GPG keys
sudo apt-get -y install ca-certificates curl
# install GNU Privacy Guard
sudo apt-get -y install gnupg
# install keyrings stuff idk
sudo install -m 0755 -d /etc/apt/keyrings


# install tools for managing ppa repositories
sudo apt-get -y install software-properties-common
sudo apt-get -y install unzip
# ensure we have bash-completion
sudo apt-get -y install bash-completion

#sudo apt-get -y install build-essential

#sudo apt-get -y install libssl-dev
#sudo apt-get -y install libffi-dev
# required for Openstack SDK, Ansible
sudo apt-get -y install python3-dev
sudo apt-get -y install python3-pip

# Add graph builder tool for Terraform
sudo apt-get -y install graphviz

# install Ansible
pip install --upgrade ansible argcomplete
# activate autocomplete for ansible
activate-global-python-argcomplete

# Install Terraform (https://developer.hashicorp.com/terraform/downloads)
# add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo tee /etc/apt/keyrings/hashicorp-archive-keyring.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/hashicorp-archive-keyring.asc
# add the repository to Apt sources:
echo "deb [signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.asc] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
# install
sudo apt-get update
sudo apt-get -y install terraform
# Enable tab completion
# Ensure bashrc exists
touch /home/vagrant/.bashrc
# Install autocomplete (sudo is needed to use -u to change user, because script is running as root)
sudo -u vagrant terraform -install-autocomplete

# install OpenStack SDK modules
#pip install python-openstackclient

# Install Google Cloud SDK (https://cloud.google.com/sdk/docs/install)
# add GoogleCloud GPG key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /etc/apt/keyrings/cloud.google.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/cloud.google.asc
# add the repository to Apt sources:
echo "deb [signed-by=/etc/apt/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt cloud-sdk main" | \
    sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null
# install
sudo apt-get update
sudo apt-get -y install google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin
# add autocomplete
for file in $(find /usr -type f -wholename "**/google-cloud-sdk/*completion.bash.inc"); do
    echo ". ${file}" >> /home/vagrant/.bashrc
done

# Install Kubernetes Controller
sudo snap install kubectl --classic
#sudo snap install kubeadm --classic
#sudo snap install kubelet --classic
# install autocomplete for kubernetes
echo ". <(kubectl completion bash)" >> /home/vagrant/.bashrc
#echo ". <(kubeadm completion bash)" >> /home/vagrant/.bashrc

# Install Amazon AWS-CLI
#sudo apt-get -y install awscli

# Install Docker
# add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc
# add the repository to Apt sources:
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# install
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Allow non-root users to use docker
# create docker group
sudo groupadd docker
# add user to the group
sudo usermod -aG docker vagrant
# refresh groups
newgrp docker

# Configure gcloud for stuff idk idc
sudo -u vagrant gcloud auth activate-service-account --key-file="$(find /home/vagrant/project -type f -name "agisit*.json" | sed 1q)"

#-- moved to terraform
# Configure docker for gcloud in us-west4 (change to another region if needed)
# sudo -u vagrant gcloud auth configure-docker us-west4-docker.pkg.dev --quiet

# Clean up cached packages
sudo apt-get clean all

# Enable terminal color
sed -i -E 's/^#?(force_color_prompt=).+$/\1yes/' /home/vagrant/.bashrc

# Gotta set the time right!
sudo systemctl restart systemd-timesyncd
