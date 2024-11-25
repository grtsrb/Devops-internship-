#!/bin/bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings 
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo groupadd docker
sudo usermod -aG docker $USER 

sudo su - $USER

sudo systemctl restart docker

docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}

docker pull grtalca/python-app

mkdir /home/$USER/docker
cd /home/$USER/docker

cat <<EOF > docker-compose.yaml
version: "3.9"
services:
  python-application:
    image: grtalca/python_app
    container_name: python-application
    environment:
      DATABASE_HOSTNAME: ${DATABASE_HOSTNAME}
      DATABASE_NAME: ${DATABASE_NAME}
      DATABASE_PORT: ${DATABASE_PORT}
      DATABASE_USERNAME: ${DATABASE_USERNAME}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD}
      SECRET_KEY: ${SECRET_KEY}
      ALGORITHM: ${ALGORITHM}
    ports:
      - 8080:8080
    command: bash -c "alembic upgrade head && gunicorn app.main:app -w 3 -b 0.0.0.0:8080 -k uvicorn.workers.UvicornWorker"
EOF

docker compose up -d 