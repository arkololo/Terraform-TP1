# Guide : Créer le dépôt GitHub Ansible

Ce guide explique comment créer le dépôt GitHub qui sera cloné par Terraform lors du déploiement.

## 📁 Structure du dépôt GitHub

Le dépôt GitHub DOIT contenir à la racine :

```
ansible-wordpress/
├── playbook.yml          (playbook Ansible principal)
├── inventory.ini         (inventory Ansible)
├── docker-compose.yml    (docker-compose pour WordPress)
└── README.md             (documentation)
```

## 🔧 Créer le dépôt

### Option 1 : Depuis GitHub Web Interface

1. Aller à : https://github.com/new
2. Repository name : `ansible-wordpress`
3. Description : "Ansible playbook for WordPress deployment with Docker"
4. Visibility : Public (ou Private si préféré)
5. Initialize with README : YES
6. Click "Create repository"

### Option 2 : Depuis la ligne de commande

```bash
# Créer le dépôt local
mkdir ansible-wordpress
cd ansible-wordpress
git init

# Copier les fichiers (depuis ce projet)
cp ../Terraform-TP1/ansible/playbook.yml .
cp ../Terraform-TP1/ansible/inventory.ini .
cp ../Terraform-TP1/ansible/docker-compose.yml .

# Créer README
cat > README.md << 'EOF'
# Ansible WordPress Deployment

Playbook Ansible pour déployer WordPress avec Docker & MySQL.

## Utilisation

ansible-playbook playbook.yml -i inventory.ini

## Contenu

- `playbook.yml` : Playbook Ansible principal
- `inventory.ini` : Inventory Ansible
- `docker-compose.yml` : Stack Docker (MySQL + WordPress + phpMyAdmin)

EOF

# Configurer Git
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Pousser vers GitHub
git add .
git commit -m "Initial commit: WordPress Ansible playbook"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/ansible-wordpress.git
git push -u origin main
```

## 📋 Contenu des fichiers

### playbook.yml
Doit se trouver à la racine du repo avec les tâches :
- Mise à jour système
- Installation Docker
- Installation Docker Compose
- Création /opt/wordpress
- Déploiement docker-compose.yml
- Vérification services

(Voir : Terraform-TP1/ansible/playbook.yml)

### inventory.ini
Doit définir au minimum :

```ini
[webservers]
web_server ansible_host=10.0.100.20 ansible_user=debian ansible_port=22

[webservers:vars]
ansible_python_interpreter=/usr/bin/python3
```

### docker-compose.yml
Stack Docker avec :
- MySQL 8.0
- WordPress latest
- phpMyAdmin

(Voir : Terraform-TP1/ansible/docker-compose.yml)

## 🔗 Configuration Terraform

Dans terraform.tfvars, configurer :

```hcl
github_repo_url = "https://github.com/YOUR_USERNAME/ansible-wordpress.git"
github_repo_branch = "main"
```

## ✅ Vérifier le dépôt

Avant de déployer, tester :

```bash
# Cloner localement
git clone https://github.com/YOUR_USERNAME/ansible-wordpress.git
cd ansible-wordpress

# Vérifier les fichiers
ls -la
# Doit contenir: playbook.yml, inventory.ini, docker-compose.yml, README.md

# Valider YAML
yamllint playbook.yml
yamllint inventory.ini

# Valider Ansible
ansible-lint playbook.yml
```

## 🚀 Utilisation avec Terraform

Une fois configuré et poussé à GitHub :

1. Mettre à jour terraform.tfvars avec l'URL du repo
2. Exécuter : `terraform apply -auto-approve`
3. Terraform va :
   - Créer les VMs
   - Cloud-init va cloner le repo dans VM Ansible
   - Ansible va exécuter playbook.yml automatiquement
   - WordPress sera déployé

## 📝 Notes importantes

- Le repo DOIT être PUBLIC (sinon git clone échouera dans la VM)
- Les fichiers DOIVENT être à la racine (pas de sous-dossiers)
- playbook.yml DOIT être nommé exactement "playbook.yml"
- inventory.ini DOIT être nommé exactement "inventory.ini"
- Les chemins dans ansible_init.yaml attendent ces noms

## 🔒 Pour un repo PRIVATE

Si le repo est privé, il faut ajouter une clé SSH :

1. Générer clé SSH :
   ssh-keygen -t ed25519 -f ~/.ssh/github_deploy -N ""

2. Ajouter la clé à GitHub (Settings → Deploy keys)

3. Dans cloud-init/ansible_init.yaml, ajouter :
   ```bash
   cat > /home/ubuntu/.ssh/github_deploy << 'EOFKEY'
   [Contenu clé privée]
   EOFKEY
   
   git clone git@github.com:YOUR_USERNAME/ansible-wordpress.git /home/ubuntu/ansible-repo
   ```

## 🐛 Troubleshooting

❌ "Repository not found"
→ Vérifier l'URL est correcte et publique

❌ "Failed to clone repository"
→ Vérifier les fichiers sont à la racine

❌ "playbook.yml not found"
→ Vérifier le nom exacte du fichier

## 📚 Ressources

- [GitHub Creating a repo](https://docs.github.com/en/get-started/quickstart/create-a-repo)
- [Ansible Documentation](https://docs.ansible.com/)
- [Docker Compose](https://docs.docker.com/compose/)

---

**Résumé :** Créez un repo GitHub public avec playbook.yml, inventory.ini, docker-compose.yml à la racine, puis mettez à jour terraform.tfvars avec l'URL.
