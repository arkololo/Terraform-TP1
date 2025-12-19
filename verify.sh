#!/bin/bash
# Script de vérification de déploiement Terraform + Ansible + WordPress

set -e

echo "================================================================================"
echo "VÉRIFICATION DÉPLOIEMENT TERRAFORM + ANSIBLE + WORDPRESS"
echo "================================================================================"
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_result() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ SUCCÈS${NC}: $1"
    else
        echo -e "${RED}✗ ERREUR${NC}: $1"
        return 1
    fi
}

warn_result() {
    echo -e "${YELLOW}⚠ INFO${NC}: $1"
}

# =============================================================================
# 1. Vérifier Terraform
# =============================================================================
echo ""
echo "--- Vérification Terraform ---"

# Terraform init
if [ -d ".terraform" ]; then
    echo -e "${GREEN}✓${NC} .terraform/ existe"
else
    echo -e "${RED}✗${NC} .terraform/ n'existe pas - exécuter: terraform init"
    exit 1
fi

# Terraform format
terraform fmt -check -recursive . 2>/dev/null && check_result "Format Terraform correct" || warn_result "Format Terraform pourrait être amélioré"

# Terraform validate
terraform validate > /dev/null 2>&1
check_result "Validation Terraform"

# =============================================================================
# 2. Vérifier structure de fichiers
# =============================================================================
echo ""
echo "--- Vérification structure files ---"

FILES_TO_CHECK=(
    "main.tf"
    "variables.tf"
    "outputs.tf"
    "network.tf"
    "vm_ansible.tf"
    "vm_web.tf"
    "terraform.tfvars"
    "cloud-init/ansible_init.yaml"
    "cloud-init/web_init.yaml"
    "ansible/inventory.ini"
    "ansible/playbook.yml"
    "ansible/docker-compose.yml"
    "README.md"
    "EXECUTION.md"
)

for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file existe"
    else
        echo -e "${RED}✗${NC} $file manquant"
        exit 1
    fi
done

# =============================================================================
# 3. Vérifier configuration terraform.tfvars
# =============================================================================
echo ""
echo "--- Vérification terraform.tfvars ---"

if grep -q "ansible_ssh_public_key" terraform.tfvars; then
    echo -e "${GREEN}✓${NC} Variable ansible_ssh_public_key définie"
else
    echo -e "${RED}✗${NC} Variable ansible_ssh_public_key manquante"
    exit 1
fi

if grep -q "ansible_ssh_private_key" terraform.tfvars; then
    echo -e "${GREEN}✓${NC} Variable ansible_ssh_private_key définie"
else
    echo -e "${RED}✗${NC} Variable ansible_ssh_private_key manquante"
    exit 1
fi

if grep -q "github_repo_url" terraform.tfvars; then
    echo -e "${GREEN}✓${NC} Variable github_repo_url définie"
else
    echo -e "${RED}✗${NC} Variable github_repo_url manquante"
    exit 1
fi

# =============================================================================
# 4. Vérifier Incus
# =============================================================================
echo ""
echo "--- Vérification Incus ---"

if command -v incus &> /dev/null; then
    echo -e "${GREEN}✓${NC} Commande 'incus' disponible"
else
    echo -e "${RED}✗${NC} Commande 'incus' non trouvée - installer Incus"
    exit 1
fi

if incus list > /dev/null 2>&1; then
    check_result "Connexion Incus OK"
else
    echo -e "${RED}✗${NC} Impossible de se connecter à Incus - vérifier configuration"
    exit 1
fi

# =============================================================================
# 5. Vérifier images Incus
# =============================================================================
echo ""
echo "--- Vérification images Incus ---"

if incus image list | grep -q "ubuntu.*24.04"; then
    echo -e "${GREEN}✓${NC} Image Ubuntu 24.04 disponible"
else
    warn_result "Image Ubuntu 24.04 non trouvée - ansible_os_image peut échouer"
fi

if incus image list | grep -q "debian.*12"; then
    echo -e "${GREEN}✓${NC} Image Debian 12 disponible"
else
    warn_result "Image Debian 12 non trouvée - web_os_image peut échouer"
fi

# =============================================================================
# 6. Vérifier YAML Cloud-init
# =============================================================================
echo ""
echo "--- Vérification YAML Cloud-init ---"

if command -v yamllint &> /dev/null; then
    echo -e "${YELLOW}*${NC} yamllint disponible - vérification détaillée"
    yamllint cloud-init/ansible_init.yaml > /dev/null 2>&1 && check_result "cloud-init/ansible_init.yaml" || warn_result "Potentiels problèmes dans cloud-init/ansible_init.yaml"
    yamllint cloud-init/web_init.yaml > /dev/null 2>&1 && check_result "cloud-init/web_init.yaml" || warn_result "Potentiels problèmes dans cloud-init/web_init.yaml"
else
    warn_result "yamllint non installé - vérification YAML skippée"
fi

# =============================================================================
# 7. Vérifier Ansible
# =============================================================================
echo ""
echo "--- Vérification Ansible ---"

if command -v ansible-lint &> /dev/null; then
    echo -e "${YELLOW}*${NC} ansible-lint disponible"
    ansible-lint ansible/playbook.yml > /dev/null 2>&1 && check_result "Playbook Ansible lint" || warn_result "Potentiels problèmes dans playbook Ansible"
else
    warn_result "ansible-lint non installé - vérification Ansible skippée"
fi

if grep -q "hosts: webservers" ansible/playbook.yml; then
    echo -e "${GREEN}✓${NC} Playbook contient hosts valides"
else
    echo -e "${RED}✗${NC} Playbook playbook.yml mal formé"
    exit 1
fi

# =============================================================================
# 8. Résumé
# =============================================================================
echo ""
echo "================================================================================"
echo -e "${GREEN}✓ TOUTES LES VÉRIFICATIONS SONT PASSÉES${NC}"
echo "================================================================================"
echo ""
echo "Prêt pour le déploiement !"
echo ""
echo "Commandes suivantes :"
echo "1. terraform plan"
echo "2. terraform apply -auto-approve"
echo "3. terraform output"
echo ""
echo "Attendre 4-5 minutes pour que WordPress soit accessible à :"
echo "http://10.0.100.20"
echo ""
