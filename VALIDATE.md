# Script de test - Valider la configuration Terraform

Utilisez l'une des commandes suivantes pour valider :

## Windows (cmd.exe)

```cmd
# Naviguer au répertoire
cd c:\Users\Tomy Rulliat\Desktop\CPE-cours\2emeAnnee\DevOps\DEVOPS-2\Terraform-github\Terraform-TP1

# Valider la configuration
tofu validate

# Voir le plan
tofu plan

# Déployer
tofu apply -auto-approve
```

## PowerShell

```powershell
cd 'c:\Users\Tomy Rulliat\Desktop\CPE-cours\2emeAnnee\DevOps\DEVOPS-2\Terraform-github\Terraform-TP1'
tofu validate
tofu plan
tofu apply -auto-approve
```

## Bash/Linux/Mac

```bash
cd ~/Desktop/CPE-cours/2emeAnnee/DevOps/DEVOPS-2/Terraform-github/Terraform-TP1
tofu validate
tofu plan
tofu apply -auto-approve
```

## Si tofu n'est pas trouvé

Installer OpenTofu :
- Windows : https://opentofu.org/docs/intro/install/
- Ajouter au PATH
- Vérifier : `tofu version`

## Structure validée

✓ main.tf                   - Provider Incus
✓ variables.tf              - Variables déclarées
✓ terraform.tfvars          - Valeurs personnalisées
✓ network.tf                - Réseau OVN
✓ vm_ansible.tf             - VM Ansible + Cloud-init
✓ vm_web.tf                 - VM Web + Cloud-init
✓ outputs.tf                - Outputs WordPress + IPs
✓ cloud-init/ansible_init.yaml  - Script Cloud-init Ansible
✓ cloud-init/web_init.yaml      - Script Cloud-init Web
✓ ansible/playbook.yml          - Playbook Ansible
✓ ansible/inventory.ini         - Inventory Ansible
✓ ansible/docker-compose.yml    - Docker Compose WordPress

## Prêt pour le déploiement !
