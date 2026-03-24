#!/bin/bash

# ========================
# Update System
# ========================
sudo apt update -y

# ========================
# Install Java (Temurin 17)
# ========================
sudo mkdir -p /etc/apt/keyrings

wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public \
| sudo tee /etc/apt/keyrings/adoptium.asc > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] \
https://packages.adoptium.net/artifactory/deb \
$(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" \
| sudo tee /etc/apt/sources.list.d/adoptium.list

sudo apt update -y
sudo apt install temurin-17-jdk -y

java -version

# ========================
# Install Jenkins 
# ========================
sudo mkdir -p /etc/apt/keyrings

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
| sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
sudo apt install jenkins -y

sudo systemctl start jenkins
sudo systemctl enable jenkins

# ========================
# Install Docker
# ========================
sudo apt-get install docker.io -y

sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker ubuntu
sudo chmod 666 /var/run/docker.sock

# ========================
# Run SonarQube
# ========================
docker run -d --name sonar \
-p 9000:9000 \
-e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
sonarqube:lts-community

# ========================
# Install Trivy
# ========================
sudo apt-get install wget apt-transport-https gnupg lsb-release unzip -y

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
| gpg --dearmor \
| sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
https://aquasecurity.github.io/trivy-repo/deb \
$(lsb_release -sc) main" \
| sudo tee /etc/apt/sources.list.d/trivy.list

sudo apt-get update
sudo apt-get install trivy -y

# ========================
# Install AWS CLI v2
# ========================
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws --version

# ========================
# Install kubectl
# ========================
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl
sudo mv kubectl /usr/local/bin/

kubectl version --client

# ========================
# Run Prometheus
# ========================
docker run -d --name prometheus \
-p 9090:9090 \
prom/prometheus

# ========================
# Run Grafana
# ========================
docker run -d --name grafana \
-p 3000:3000 \
grafana/grafana

# ========================
# Final Output
# ========================
echo "✅ Setup Complete!"
echo "Jenkins:     http://<your-ip>:8080"
echo "SonarQube:   http://<your-ip>:9000"
echo "Prometheus:  http://<your-ip>:9090"
echo "Grafana:     http://<your-ip>:3000"