# 🏥 HealthSync: Enterprise Healthcare K8s Dashboard

**HealthSync** is a high-availability hospital management system deployed on Microsoft Azure. The project demonstrates a full-stack DevOps lifecycle, featuring *Infrastructure as Code (IaC)*, container orchestration with *Kubernetes*, and a professional analytics dashboard.
---

## 🚀 Architecture Overview

The system is built on a **"Cloud-Native"** philosophy, ensuring that each component—from the database to the load balancer—is automated and scalable.

* **Cloud Infrastructure**: Provisioned via Terraform, including a Virtual Network (VNet), Network Security Groups (NSG), and an Ubuntu 24.04 Node.

* **Load Balancing**: An Azure Standard Load Balancer (ALB) manages external traffic, routing Port 80 to the internal Kubernetes NodePort.

* **Orchestration**: Minikube runs the containerized services within the Azure VM.

* **Database**: A persistent PostgreSQL instance with automated schema initialization via Kubernetes ConfigMaps.

* **CI/CD**: GitHub Actions automates the building of Docker images and triggers SSH-based deployment updates to the VM.

---

## 🛠️ Technology Stack

* **Layer**	    |   **Technology**

* Cloud         |   Microsoft Azure

* IaC           |   Terraform

* Orchestration | 	Kubernetes (Minikube)

* Backend       |   Python 3.11 (Flask), Psycopg2

* Frontend      |   HTML5, Bootstrap 5, Chart.js, Vanilla JS

* Database      |   PostgreSQL 15

* CI/CD	        |   GitHub Actions, Docker Hub

---

## 📂 Project Structure

```text

.
├── .github/workflows/  # CI/CD Pipeline (build & deploy)
├── terraform/          # Infrastructure definitions (ALB, VNet, VM)
├── k8s/                # Kubernetes Manifests (Deployments, Services, ConfigMaps)
├── app/
│   ├── frontend/       # Bootstrap 5 Dashboard & Chart.js logic
│   └── backend/        # Flask REST API & PostgreSQL connectivity
└── scripts/            # Automation scripts for VM initialization
```

---

## ⚙️ Installation & Deployment

**1. Provision Infrastructure**

Ensure you have your Azure credentials configured locally.

*cd terraform*

*terraform init*

*terraform apply -auto-approve*

**2. Initialize the VM**

SSH into the newly created Azure VM using the *vm_ssh_public_ip* from the Terraform output.

*ssh azureuser@<VM_PUBLIC_IP>*

*cd scripts/*

*chmod +x setup.sh*

*./setup.sh*

**3. Establish the Traffic Bridge**

Since Minikube operates on an internal Docker network, bind the services to the VM's interface for the ALB to access:

*kubectl port-forward --address 0.0.0.0 service/healthcare-svc 32000:80 > frontend.log 2>&1 &*

*kubectl port-forward --address 0.0.0.0 service/healthcare-svc 31000:5000 > backend.log 2>&1 &*

---

## 📊 Dashboard Features

* **Real-time Analytics**: Visual representation of patient conditions using Chart.js.

* **System Health Monitoring**: Live backend status indicator and server-time synchronization.

* **Database Integration**: Searchable patient records pulled directly from the PostgreSQL cluster.

* **Responsive UI**: A professional sidebar-based layout optimized for clinical workstations.

---
   
## 🛡️ Security & Optimization

* **NSG Hardening**: Traffic is restricted to specific ports (22, 80, 31000, 32000) to minimize attack surface.

* **Multi-Stage Docker Builds**: Optimized image sizes for faster deployment and reduced storage costs.

* **Automated DB Init**: SQL scripts are mounted via ConfigMaps, ensuring the database is production-ready upon deployment.

---

## 👨‍💻 Author

**Simarjit Singh** DevOps Engineer | Azure Administrator
