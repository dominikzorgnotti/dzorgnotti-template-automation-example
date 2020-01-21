# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

## Install Docker CE.
sudo apt-get update
# this throws an error as ssh does not have an interactive terminal but works otherweise fine
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose

sudo mv /tmp/daemon.json /etc/docker/daemon.json 

sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker
