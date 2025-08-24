# 🚀 Pipeline Symphony – DevOps Project

**Pipeline Symphony** is a student DevOps project that demonstrates a full CI/CD and monitoring stack using only **AWS Free Tier resources**.  

It combines: **Terraform, Ansible, Docker, Kubernetes, Jenkins, Maven, and Nagios** on Debian 13 EC2 instances.

---

## 📦 Project Overview
- **pipeline-symphony (t2.micro)**  
  Manual EC2 instance → acts as the **main DevOps control node**.  
  Runs: Jenkins, Maven, Nagios Core.

- **terraform-ec2 (t3a.small)**  
  Created via **Terraform** → runs **Kubernetes (single node)** with containerd.  
  Hosts application deployments & monitored by Nagios NRPE.

- **Application**  
  A sample Go + HTMX web app (`symphony`) built via Maven & Docker, deployable on both Docker and Kubernetes.

---

## 🔑 Prerequisites
- AWS account with Free Tier enabled
- SSH key pair (`symphony.pem`)
- Git & Terraform installed locally

---

## ⚙️ Setup Instructions

### 1. Launch Main Control Node
```bash
# Manual EC2 creation (t2.micro, Debian 13)
ssh -i "symphony.pem" admin@<PIPELINE_SYMPHONY_PUBLIC_IP>
```

Clone the repo:
```bash
git clone https://github.com/bluesboynix/symphony.git
```

---

### 2. Provision Kubernetes Node via Terraform
```bash
cd symphony/infra
terraform init
terraform apply -auto-approve
```

SSH into the new instance:
```bash
ssh -i "symphony.pem" admin@<TERRAFORM_EC2_PUBLIC_IP>
```

---

### 3. Prepare Kubernetes Node
- Install Docker & containerd  
- Disable swap  
- Install `kubelet`, `kubeadm`, `kubectl` (v1.31)  
- Initialize cluster:
  ```bash
  sudo kubeadm init --pod-network-cidr=10.244.0.0/16 \
      --cri-socket=unix:///run/containerd/containerd.sock \
      --ignore-preflight-errors=NumCPU,Mem
  ```
- Install **Flannel CNI**  
- Untaint control-plane (single-node):
  ```bash
  kubectl taint nodes --all node-role.kubernetes.io/control-plane-
  ```

Verify:
```bash
kubectl get nodes
kubectl get pods -A
```

---

### 4. Deploy Application

#### Run via Docker (on any node)
```bash
cd ~/symphony
docker build -t symphony-app .
docker run -d --name symphony -p 8080:8080 symphony-app
```

Visit:  
`http://<EC2_PUBLIC_IP>:8080/`

#### Run via Kubernetes
```bash
kubectl apply -f k8s/symphony-deployment.yaml
kubectl get svc
```

---

### 5. Jenkins Setup (on pipeline-symphony)
```bash
sudo apt update && sudo apt install -y openjdk-11-jdk maven jenkins
```

Open Jenkins:  
`http://<PIPELINE_SYMPHONY_PUBLIC_IP>:8080`

- Install suggested plugins  
- Configure Maven (`/usr/share/maven`)  
- Create a Freestyle job:
  - **Source Code Management** → Git (`https://github.com/bluesboynix/symphony.git`)  
  - **Build** → Invoke top-level Maven targets (`clean install`)

---

### 6. Nagios Monitoring
On **pipeline-symphony**:
- Install Nagios Core + Plugins
- Configure web access at `http://<PIPELINE_SYMPHONY_PUBLIC_IP>/nagios`

On **terraform-ec2**:
- Install **NRPE** & plugins
- Allow pipeline-symphony private IP in `/etc/nagios/nrpe.cfg`

Define host in `/usr/local/nagios/etc/servers/terraform-ec2.cfg`:
```cfg
define host {
    use       linux-server
    host_name terraform-ec2
    address   <PRIVATE_IP>
}

define service {
    use                   generic-service
    host_name             terraform-ec2
    service_description   Check Load
    check_command         check_nrpe!check_load
}
```

Verify config & restart Nagios:
```bash
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
sudo systemctl restart nagios
```

---

## ✅ Deliverables
- **Infrastructure as Code (Terraform)** – reproducible AWS infra
- **Provisioning (Ansible/manual)** – Docker + Kubernetes setup
- **CI/CD (Jenkins + Maven)** – build pipeline from GitHub
- **App Deployment (Docker & Kubernetes)** – sample Go app
- **Monitoring (Nagios + NRPE)** – system & service checks

---

## 🌐 Access Points
- Jenkins: `http://<PIPELINE_SYMPHONY_PUBLIC_IP>:8080`
- Nagios: `http://<PIPELINE_SYMPHONY_PUBLIC_IP>/nagios`
- App (Docker/K8s): `http://<TERRAFORM_EC2_PUBLIC_IP>:8080`

---

👉 This README shows the **end-to-end DevOps pipeline** using free-tier AWS resources.
