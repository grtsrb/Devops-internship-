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

echo ${DOCKER_USERNAME}
echo ${DOCKER_PASSWORD}

sudo docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}

sudo docker pull grtalca/python-app

IP_ADDR=$(curl https://ifconfig.me/)

sudo docker container run -d \
    -e DATABASE_HOSTNAME=${DATABASE_HOSTNAME} \
    -e DATABASE_NAME=${DATABASE_NAME} \
    -e DATABASE_PORT=${DATABASE_PORT} \
    -e DATABASE_USERNAME=${DATABASE_USERNAME} \
    -e DATABASE_PASSWORD=${DATABASE_PASSWORD} \
    -e SECRET_KEY=${SECRET_KEY} \
    -e ALGORITHM=${ALGORITHM} \
    -p 8080:8080 \
    --name python-web \
    grtalca/python-app \
    bash -c "alembic upgrade head && gunicorn app.main:app -w 3 -b 0.0.0.0:8080 -k uvicorn.workers.UvicornWorker"