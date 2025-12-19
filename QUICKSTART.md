================================================================================
QUICK START - DÉMARRAGE RAPIDE
================================================================================

⚡ DÉPLOIEMENT EN 3 ÉTAPES

ÉTAPE 1 : CONFIGURER
====================
Éditer terraform.tfvars :
1. Remplacer ansible_ssh_public_key par votre clé publique
2. Remplacer ansible_ssh_private_key par votre clé privée

✅ Comment générer les clés :
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""

ÉTAPE 2 : DÉPLOYER
==================
```bash
cd c:\Users\Tomy Rulliat\Desktop\CPE-cours\2emeAnnee\DevOps\DEVOPS-2\Terraform-github\Terraform-TP1
tofu init
tofu plan
tofu apply -auto-approve
```

⏱️ Attendre 4-5 minutes...

ÉTAPE 3 : ACCÉDER
=================
```bash
terraform output wordpress_access
```

Puis naviguer vers : http://10.0.100.20

================================================================================
VÉRIFIER LE STATUT
================================================================================

Voir les URLs d'accès :
tofu output wordpress_access

Vérifier l'exécution Ansible :
incus exec Ansible -- tail -50 /var/log/cloud-init-output.log

Vérifier les services Docker :
incus exec Web -- docker ps

================================================================================
SUPPRIMER (NETTOYAGE)
================================================================================

tofu destroy -auto-approve

================================================================================
TROUBLESHOOTING RAPIDE
================================================================================

❌ terraform init échoue
→ incus list
→ Vérifier connectivité Incus

❌ terraform apply échoue
→ Vérifier terraform.tfvars (syntaxe YAML/HCL)
→ Vérifier clés SSH

❌ Ansible n'exécute pas playbook
→ incus exec Ansible -- tail -100 /var/log/cloud-init-output.log
→ Attendre 90 secondes

❌ WordPress inaccessible
→ incus exec Web -- docker ps
→ Attendre que tous les conteneurs soient "Up"
→ Vérifier : curl -I http://10.0.100.20

================================================================================
FICHIERS CLÉS
================================================================================

À ÉDITER :
- terraform.tfvars         (clés SSH, paramètres)

À CONSULTER :
- README.md                (documentation complète)
- EXECUTION.md             (guide détaillé)
- terraform.tfvars.example (exemple configuration)

TERRAFORM :
- main.tf, variables.tf, outputs.tf, network.tf
- vm_ansible.tf, vm_web.tf

AUTOMATION :
- cloud-init/ansible_init.yaml    (Cloud-init VM Ansible)
- cloud-init/web_init.yaml        (Cloud-init VM Web)
- ansible/playbook.yml            (Playbook Ansible)
- ansible/inventory.ini           (Inventory Ansible)
- ansible/docker-compose.yml      (Docker Compose)

================================================================================
ARCHITECTURE
================================================================================

Réseau OVN "Main" (10.0.100.0/24)
├─ VM Ansible (10.0.100.10)
│  └─ Ubuntu 24.04 | 1 CPU | 1GB RAM | 16GB Disk
│     └─ openssh, git, ansible
│        └─ Exécute playbook vers Web VM
└─ VM Web (10.0.100.20)
   └─ Debian 12 | 1 CPU | 2GB RAM | 32GB Disk
      └─ Docker + Docker Compose
         ├─ MySQL 8.0
         ├─ WordPress latest
         └─ phpMyAdmin

✅ Automatisation complète :
terraform apply → Cloud-init → Ansible playbook → WordPress ✓

================================================================================
PARAMETRES PERSONNALISABLES
================================================================================

terraform.tfvars :
- network_subnet           : Sous-réseau IP (défaut: 10.0.100.0/24)
- ansible_cpu/memory       : Ressources VM Ansible
- web_cpu/memory           : Ressources VM Web
- github_repo_url          : Dépôt GitHub avec playbooks
- security_protection_delete : Protection destruction (true/false)

================================================================================
URLS D'ACCÈS (APRÈS DÉPLOIEMENT)
================================================================================

WordPress              : http://10.0.100.20
Admin WordPress        : http://10.0.100.20/wp-admin
phpMyAdmin            : http://10.0.100.20:8080

Identifiants phpMyAdmin :
- User: wordpress
- Pass: wordpress_pass

================================================================================
COMMANDES ESSENTIELLES
================================================================================

Init          : tofu init
Plan          : tofu plan
Deploy        : tofu apply -auto-approve
Destroy       : tofu destroy -auto-approve
Status        : tofu show
Outputs       : tofu output
Validate      : tofu validate
Format        : tofu fmt

Vérifier VMs  : incus list
Logs Ansible  : incus exec Ansible -- tail -50 /var/log/cloud-init-output.log
Docker status : incus exec Web -- docker ps
Se connecter  : incus exec VMNAME -- bash

================================================================================
DURÉE D'EXÉCUTION
================================================================================

terraform init          : ~30 sec
terraform plan          : ~5 sec
terraform apply         : ~2-3 min (création VMs)
Cloud-init (auto)       : ~3-5 min (installation packages)
Ansible playbook (auto) : ~2-3 min (Docker + WordPress)
TOTAL                   : ~10 min jusqu'à WordPress accessible

================================================================================
NOTES IMPORTANTES
================================================================================

1. Les clés SSH doivent être en format ED25519 (OpenSSH)
2. Tout est automatisé - aucune intervention manuelle requise
3. Attendre 4-5 min avant d'accéder à WordPress
4. Les logs cloud-init aident au troubleshooting
5. terraform destroy supprime TOUT (réseau + VMs + données)
6. security_protection_delete = true empêche terraform destroy

================================================================================
ALLER PLUS LOIN
================================================================================

Voir README.md pour :
- Architecture détaillée
- Configuration complète
- Troubleshooting avancé
- Ressources et documentation

Voir EXECUTION.md pour :
- Guide étape par étape
- Vérification complète
- Commandes de troubleshooting

================================================================================
