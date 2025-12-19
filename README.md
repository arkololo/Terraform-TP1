# Infrastructure OpenTofu - WordPress automatisé via Ansible & Docker

Déploiement complet et automatisé d'une infrastructure de production avec :
- **Réseau OVN** (IPv4 uniquement)
- **VM Ansible** (orchestration)
- **VM Web** (WordPress + MySQL + phpMyAdmin)
- **Automatisation complète** (Cloud-init + Ansible playbook)

---

## 📋 Architecture

```
┌─────────────────────────────────────────────────────────┐
│           Réseau OVN - Main (10.0.100.0/24)            │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────┐    ┌──────────────────────┐  │
│  │  VM Ansible          │    │  VM Web              │  │
│  ├──────────────────────┤    ├──────────────────────┤  │
│  │ 10.0.100.10          │    │ 10.0.100.20          │  │
│  │ Ubuntu 24.04         │    │ Debian 12            │  │
│  │ 1 CPU / 1GB RAM      │    │ 1 CPU / 2GB RAM      │  │
│  │ 16GB disk            │    │ 32GB disk            │  │
│  ├──────────────────────┤    ├──────────────────────┤  │
│  │ • openssh-server     │    │ • openssh-server     │  │
│  │ • git                │    │ • Docker             │  │
│  │ • ansible            │    │ • Docker Compose     │  │
│  ├──────────────────────┤    ├──────────────────────┤  │
│  │ Cloud-init:          │    │ Cloud-init:          │  │
│  │ • Gen SSH key        │    │ • SSH authorized_keys│  │
│  │ • Clone repo GitHub  │    │ • Attendre Ansible   │  │
│  │ • Run playbook auto  │    │                      │  │
│  └──────────────────────┘    ├──────────────────────┤  │
│         │                     │ Docker Services:     │  │
│         │ SSH + Ansible       │ • MySQL 8.0          │  │
│         └────────────────────>│ • WordPress latest   │  │
│                               │ • phpMyAdmin         │  │
│                               └──────────────────────┘  │
│                                      │                  │
│                                      └─────────────────>│
│                                    http://10.0.100.20   │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Démarrage Rapide

### 1. Initialiser OpenTofu
```bash
cd c:\Users\Tomy Rulliat\Desktop\CPE-cours\2emeAnnee\DevOps\DEVOPS-2\Terraform-github\Terraform-TP1
tofu init
```

### 2. Valider la configuration
```bash
tofu plan
```

### 3. Appliquer la configuration (DÉPLOIEMENT COMPLET)
```bash
tofu apply -auto-approve
```

### 4. Vérifier le déploiement
```bash
tofu output
```

---

## 📝 Fichiers Terraform

### Structure du projet
```
Terraform-TP1/
├── main.tf                      # Provider + Configuration de base (OpenTofu)
├── variables.tf                 # Déclaration des variables
├── terraform.tfvars             # Valeurs des variables (À personnaliser)
├── outputs.tf                   # Outputs (accès aux ressources)
├── network.tf                   # Réseau OVN
├── vm_ansible.tf                # VM Ansible + Cloud-init
├── vm_web.tf                    # VM Web + Cloud-init
├── cloud-init/
│   ├── ansible_init.yaml        # Cloud-init pour VM Ansible
│   └── web_init.yaml            # Cloud-init pour VM Web
├── ansible/
│   ├── inventory.ini            # Inventory Ansible
│   ├── playbook.yml             # Playbook pour WordPress
│   └── docker-compose.yml       # Docker Compose
├── README.md                    # Ce fichier
└── terraform.tfvars.example     # Exemple de configuration
```

---

## 🔧 Configuration Personnalisée

### Modifier les paramètres
Éditer `terraform.tfvars` :

```hcl
# Changement d'adresses IP
ansible_ip = "10.0.100.10"
web_ip     = "10.0.100.20"

# Personnaliser les images OS
ansible_os_image = "images:ubuntu/24.04/cloud"
web_os_image     = "images:debian/12/cloud"

# Ajuster les ressources
ansible_cpu    = 1      # 1 CPU minimum
ansible_memory = "1GB"  # 1GB minimum

web_cpu        = 1      # 1 CPU minimum
web_memory     = "2GB"  # 2GB minimum

# Clés SSH (À remplacer par vos clés)
ansible_ssh_public_key = "ssh-ed25519 AAAA..."

# Repository GitHub Ansible
github_repo_url = "https://github.com/arkololo/ansible-wordpress.git"
github_repo_branch = "main"
```

---

## 🔐 Sécurité & SSH

### Générer vos clés SSH (ED25519)
```bash
# Générer une paire de clés
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "ansible@deployment"

# Afficher la clé publique
cat ~/.ssh/id_ed25519.pub

# Afficher la clé privée (PEM format)
cat ~/.ssh/id_ed25519
```

### Mettre à jour terraform.tfvars
```hcl
ansible_ssh_public_key = "ssh-ed25519 AAAA... ansible@deployment"
ansible_ssh_private_key = <<EOF
-----BEGIN OPENSSH PRIVATE KEY-----
...votre clé privée...
-----END OPENSSH PRIVATE KEY-----
EOF
```

### Configuration de sécurité
```hcl
# Protéger les VMs contre suppression accidentelle
security_protection_delete = true   # true = protégé, false = destructible

# Autoriser/interdire terraform destroy
allow_manual_destroy = true
```

---

## 📊 Flux d'Exécution Automatisée

### 1. Terraform crée les VMs
```
terraform apply
  ├─ Crée réseau OVN "Main"
  ├─ Lance VM Ansible (Ubuntu 24.04)
  │  └─ Cloud-init ubuntu_init.yaml
  └─ Lance VM Web (Debian 12)
     └─ Cloud-init web_init.yaml
```

### 2. Cloud-init VM Ansible s'exécute
```
Cloud-init ubuntu_init.yaml:
  1. Mettre à jour système (apt update/upgrade)
  2. Installer openssh-server, git, ansible
  3. Générer clé SSH ED25519
  4. Configurer authorized_keys
  5. Cloner le repo GitHub
  6. Lancer ansible-playbook automatiquement
```

### 3. Cloud-init VM Web s'exécute
```
Cloud-init web_init.yaml:
  1. Mettre à jour système (apt update/upgrade)
  2. Installer openssh-server
  3. Configurer SSH pour Ansible
  4. Ajouter clé publique Ansible dans authorized_keys
```

### 4. Ansible configure WordPress
```
Playbook Ansible:
  1. apt update + upgrade
  2. Installer Docker
  3. Installer Docker Compose
  4. Créer /opt/wordpress
  5. Déployer docker-compose.yml
  6. Lancer MySQL + WordPress + phpMyAdmin
  7. Vérifier santé des services
```

### 5. WordPress accessible
```
URLs d'accès:
  - WordPress:     http://10.0.100.20
  - Admin:         http://10.0.100.20/wp-admin
  - phpMyAdmin:    http://10.0.100.20:8080
```

---

## 📤 Outputs OpenTofu

Afficher les informations de déploiement :
```bash
tofu output
```

Résultats :
```
infrastructure_summary = {
  "ansible_vm" = {
    "ip" = "10.0.100.10"
    "name" = "Ansible"
    "os" = "images:ubuntu/24.04/cloud"
    "status" = "Running"
  }
  "network" = {
    "name" = "Main"
    "subnet" = "10.0.100.0/24"
  }
  "web_vm" = {
    "ip" = "10.0.100.20"
    "name" = "Web"
    "os" = "images:debian/12/cloud"
    "status" = "Running"
  }
}

wordpress_access = {
  "admin_url" = "http://10.0.100.20/wp-admin"
  "phpmyadmin_url" = "http://10.0.100.20:8080"
  "url" = "http://10.0.100.20"
}

ssh_access = {
  "ansible_vm" = "ssh -i /path/to/private/key ubuntu@10.0.100.10"
  "web_vm" = "ssh -i /path/to/private/key debian@10.0.100.20"
}
```

---

## 🔍 Vérification du Déploiement

### Vérifier les VMs
```bash
# Afficher l'état des VMs
incus list

# Se connecter à VM Ansible
incus exec Ansible -- sudo -u ubuntu bash

# Se connecter à VM Web
incus exec Web -- sudo -u debian bash
```

### Vérifier l'exécution Ansible
```bash
# Vérifier les logs cloud-init (VM Ansible)
incus exec Ansible -- cat /var/log/cloud-init-output.log

# Vérifier les logs playbook
incus exec Ansible -- cat /tmp/ansible-playbook.log

# Vérifier les services Docker (VM Web)
incus exec Web -- docker ps
```

### Tester WordPress
```bash
# Depuis la machine hôte
curl -I http://10.0.100.20

# Vérifier MySQL
curl http://10.0.100.20:8080
```

---

## 🗑️ Destruction

### Détruire toute l'infrastructure
```bash
# Sans confirmation
tofu destroy -auto-approve

# Avec confirmation (recommandé)
tofu destroy
```

### Si sécurité activée
```hcl
# Modifier terraform.tfvars
security_protection_delete = false

# Puis détruire
tofu destroy -auto-approve
```

---

## ⚡ Variables Disponibles

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `project` | string | HingeEnjoyer4Living2BetterYourself | Nom du projet Incus |
| `storage_pool` | string | local | Pool de stockage Incus |
| `network_name` | string | Main | Nom du réseau OVN |
| `network_subnet` | string | 10.0.100.0/24 | Subnet du réseau |
| `ansible_vm_name` | string | Ansible | Nom VM Ansible |
| `ansible_cpu` | number | 1 | CPU pour Ansible |
| `ansible_memory` | string | 1GB | RAM pour Ansible |
| `ansible_ip` | string | 10.0.100.10 | IP statique Ansible |
| `web_vm_name` | string | Web | Nom VM Web |
| `web_cpu` | number | 1 | CPU pour Web |
| `web_memory` | string | 2GB | RAM pour Web |
| `web_ip` | string | 10.0.100.20 | IP statique Web |
| `github_repo_url` | string | https://github.com/arkololo/ansible-wordpress.git | Repo GitHub |
| `security_protection_delete` | bool | false | Protection destruction |

---

## 🎯 Cas d'Usage

### Production avec protection
```hcl
security_protection_delete = true
allow_manual_destroy = false
```

### Développement/Test
```hcl
security_protection_delete = false
allow_manual_destroy = true
```

### Ressources réduites (test léger)
```hcl
ansible_memory = "512MB"
web_memory = "1GB"
```

### Ressources augmentées (production)
```hcl
ansible_cpu = 2
ansible_memory = "4GB"
web_cpu = 4
web_memory = "8GB"
```

---

## 📋 Checklist de Déploiement

- [ ] Configurer `terraform.tfvars` avec vos clés SSH
- [ ] Vérifier l'URL GitHub du repo Ansible
- [ ] Exécuter `terraform init`
- [ ] Exécuter `terraform plan`
- [ ] Exécuter `terraform apply -auto-approve`
- [ ] Attendre 2-3 min pour complétion
- [ ] Exécuter `terraform output`
- [ ] Accéder à WordPress via l'URL fournie
- [ ] Vérifier les logs Ansible
- [ ] Configurer WordPress (admin panel)

---

## 🐛 Dépannage

### VM Ansible n'exécute pas le playbook
```bash
# Vérifier les logs cloud-init
incus exec Ansible -- tail -100 /var/log/cloud-init-output.log

# Vérifier le repo cloné
incus exec Ansible -- ls -la /home/ubuntu/ansible-repo

# Relancer manuellement le playbook
incus exec Ansible -- sudo -u ubuntu ansible-playbook /home/ubuntu/ansible-repo/playbook.yml -i /home/ubuntu/ansible-repo/inventory.ini
```

### Docker ne démarre pas
```bash
# Vérifier les services Docker
incus exec Web -- docker ps

# Vérifier les logs Docker Compose
incus exec Web -- cd /opt/wordpress && docker-compose logs

# Redémarrer Docker
incus exec Web -- systemctl restart docker
```

### WordPress inaccessible
```bash
# Vérifier que les conteneurs tournent
incus exec Web -- docker ps

# Vérifier les logs WordPress
incus exec Web -- docker logs wordpress_app

# Vérifier connectivité réseau
incus exec Web -- ping 10.0.100.10
```

---

## 📚 Ressources

- [OpenTofu Incus Provider](https://registry.terraform.io/providers/lxc/incus/latest/docs)
- [Cloud-init Documentation](https://cloud-init.io/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [WordPress Official](https://wordpress.org/)

---

## 👤 Auteur & Support

**Créé pour :** Cours DevOps - TP Terraform Ansible Docker

**Dernière mise à jour :** 2025-12-19

---

## 📄 Licence

Utilisation libre pour fins éducatives.


```powershell
# Print client cert used by incus CLI
incus config trust list
# Add a new trusted client cert (on the server side)
incus config trust add
```

### SSO (GitHub) flow
If your Incus server is configured for SSO, use the CLI to log in (it opens your browser):

```powershell
incus remote add phorge https://iaas.phorge.fr
incus login phorge
```

Complete the GitHub SSO consent in the browser. After success, your local client becomes trusted and no explicit TLS paths are needed in the provider.

To confirm:

```powershell
incus remote list
```

If you prefer explicit TLS files, you can still set `client_cert_path` and `client_key_path` in `terraform.tfvars` to PEM files trusted by the server.

## Configure variables
Copy the example and adjust values:

```powershell
Copy-Item -Path terraform.tfvars.example -Destination terraform.tfvars
```

Edit `terraform.tfvars` to set `remote_addr`, `storage_pool`, etc.

## Initialize and plan
Run from this folder:

```powershell
tofu init
tofu fmt
tofu validate
tofu plan
```

Apply when ready:

```powershell
tofu apply -auto-approve
```

## What this creates
- Provider `lxc/incus` with a `remote` and `image_remote` configured.
- A sample `incus_instance` named `demo-incus` (container) using `ubuntu/24.04`.
- Root disk on `storage_pool` and optional CPU/memory limits.

## Notes
- Many base images do not include SSH. Use `ubuntu` images or add an SSH server via cloud-init or provisioning.
- For VMs, set `type = "virtual-machine"` and ensure your storage/network profiles support VMs.
- To exec into the instance:

```powershell
incus exec demo-incus -- bash
```

## Troubleshooting
- Certificate errors: confirm your client is trusted by the Incus server.
- Networking/storage: ensure the `default` profile has `bridge` and a valid `storage_pool`.
- Provider install issues: `tofu init -reconfigure` and check proxy/registry reachability.
