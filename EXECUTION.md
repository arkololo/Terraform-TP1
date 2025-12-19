================================================================================
GUIDE D'EXÉCUTION COMPLET - OPENTOFU (tofu) + ANSIBLE + WORDPRESS
================================================================================

🎯 OBJECTIF
-----------
Déployer automatiquement une infrastructure complète :
- Réseau OVN (IPv4)
- VM Ansible (orchestration)
- VM Web (WordPress + MySQL + phpMyAdmin via Docker)
- Configuration automatique via Cloud-init + Ansible playbook

⏱️ DURÉE TOTALE : ~5-10 minutes

================================================================================
ÉTAPE 1 : PRÉPARATION
================================================================================

1.1 Générer vos clés SSH (si nécessaire)
--------------------------------------
# PowerShell / Bash / Terminal
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "ansible@deployment"

# Voir clé PUBLIQUE (copier pour terraform.tfvars)
cat ~/.ssh/id_ed25519.pub
# Résultat : ssh-ed25519 AAAAC3Nza...

# Voir clé PRIVÉE (copier pour terraform.tfvars)
cat ~/.ssh/id_ed25519
# Résultat : -----BEGIN OPENSSH PRIVATE KEY----- ... -----END OPENSSH PRIVATE KEY-----

1.2 Configurer terraform.tfvars
------------------------------
IMPORTANT : Personaliser terraform.tfvars avec vos clés SSH

Éditer terraform.tfvars :
- ansible_ssh_public_key = "ssh-ed25519 VOTRE_CLE_PUBLIQUE"
- ansible_ssh_private_key = <<EOF ... VOTRE_CLE_PRIVEE ... EOF

Vérifier aussi :
- github_repo_url = URL correcte du repo avec playbook.yml
- security_protection_delete = false (pour développement)
- Toutes les adresses IP correctes

================================================================================
ÉTAPE 2 : INITIALISER TERRAFORM
================================================================================

2.1 Naviguer au répertoire du projet
------------------------------------
# Windows (cmd.exe)
cd c:\Users\Tomy Rulliat\Desktop\CPE-cours\2emeAnnee\DevOps\DEVOPS-2\Terraform-github\Terraform-TP1

2.2 Initialiser OpenTofu
--------------------------
tofu init

Résultat attendu :
```
Initializing the backend...
Successfully configured the backend "local"!
Initializing provider plugins...
- Finding latest version of lxc/incus...
...
OpenTofu has been successfully initialized!
```

================================================================================
ÉTAPE 3 : VALIDER LA CONFIGURATION
================================================================================

3.1 Vérifier le plan d'exécution
---------------------------------
tofu plan

Résultat attendu :
```
Plan: 4 to add, 0 to change, 0 destroy.
- incus_network.main
- incus_instance.ansible
- incus_instance.web
- null_resource.wait_web_ready
```

IMPORTANT : Si vous voyez des erreurs :
- Vérifier terraform.tfvars (clés SSH, URLs)
- Vérifier la connectivité Incus (incus list)
- Vérifier les images disponibles (incus image list)

================================================================================
ÉTAPE 4 : DÉPLOYER L'INFRASTRUCTURE
================================================================================

4.1 Appliquer la configuration OpenTofu
-----------------------------------------
tofu apply -auto-approve

Résultat attendu :
```
...
Apply complete! Resources have been created.

Outputs:
infrastructure_summary = {...}
wordpress_access = {...}
```

DURÉE : ~2-3 minutes

4.2 Vérifier que les VMs sont créées
------------------------------------
# Dans un autre terminal
incus list

Résultat attendu :
```
|  NAME   |  STATUS  |  IPV4  |
+---------+----------+--------+
| Ansible | RUNNING  | 10.... |
| Web     | RUNNING  | 10.... |
```

================================================================================
ÉTAPE 5 : ATTENDRE L'EXÉCUTION AUTOMATIQUE
================================================================================

5.1 Timeline d'exécution
------------------------
T+0s   : VMs lancées
T+10s  : Cloud-init commence
T+30s  : VM Ansible installe packages
T+60s  : Ansible génère clé SSH
T+90s  : Ansible clone repo GitHub
T+120s : Ansible lance playbook
T+180s : Docker démarre sur Web
T+240s : WordPress accessible

TOTAL : ~4-5 minutes

5.2 Vérifier l'avancement
-------------------------
# Logs Cloud-init (VM Ansible)
incus exec Ansible -- tail -50 /var/log/cloud-init-output.log

# Logs Playbook Ansible
incus exec Ansible -- tail -50 /tmp/ansible-playbook.log

# Services Docker (VM Web)
incus exec Web -- docker ps

ATTENDRE jusqu'à voir 3 conteneurs en "Up" :
- wordpress_mysql
- wordpress_app
- wordpress_phpmyadmin

================================================================================
ÉTAPE 6 : ACCÉDER À WORDPRESS
================================================================================

6.1 Voir les URLs
-----------------
tofu output wordpress_access

Résultat :
```
wordpress_access = {
  "admin_url" = "http://10.0.100.20/wp-admin"
  "phpmyadmin_url" = "http://10.0.100.20:8080"
  "url" = "http://10.0.100.20"
}
```

6.2 Accéder à WordPress
-----------------------
Navigateur : http://10.0.100.20
→ WordPress installation screen

6.3 Accéder à phpMyAdmin
------------------------
Navigateur : http://10.0.100.20:8080
Utilisateur : wordpress
Mot de passe : wordpress_pass

================================================================================
ÉTAPE 7 : CONFIGURER WORDPRESS (OPTIONNEL)
================================================================================

7.1 Installation initiale
--------------------------
1. Aller à http://10.0.100.20
2. Remplir les informations WordPress
3. Cliquer "Install"
4. Connexion avec admin/password

7.2 Ajouter du contenu
----------------------
1. Accès admin : http://10.0.100.20/wp-admin
2. Ajouter une page
3. Publier

================================================================================
ÉTAPE 8 : VÉRIFICATION COMPLÈTE
================================================================================

8.1 Checklist de vérification
------------------------------
✓ OpenTofu init réussi
✓ OpenTofu plan n'a pas d'erreur
✓ OpenTofu apply réussi
✓ 2 VMs créées (ansible + web)
✓ Réseau "Main" créé
✓ Cloud-init s'est exécuté (logs OK)
✓ Ansible a cloné le repo
✓ Playbook Ansible terminé
✓ Docker Compose lancé
✓ 3 conteneurs Docker actifs
✓ WordPress accessible via HTTP
✓ phpMyAdmin accessible

8.2 Commandes de vérification
-----------------------------
# Afficher tous les outputs
tofu output

# Vérifier logs Cloud-init
incus exec Ansible -- grep "Cloud-init" /var/log/cloud-init-output.log

# Vérifier services Docker
incus exec Web -- docker ps -a

# Tester connectivité
incus exec Ansible -- ping -c 3 10.0.100.20

# Tester WordPress
curl -I http://10.0.100.20

================================================================================
TROUBLESHOOTING
================================================================================

🔴 PROBLÈME : OpenTofu init échoue
SOLUTION :
- Vérifier Incus : incus list
- Vérifier provider : tofu providers
- Supprimer .terraform et réessayer

🔴 PROBLÈME : tofu apply échoue
SOLUTION :
- Vérifier terraform.tfvars (syntaxe, clés SSH)
- Vérifier images disponibles : incus image list
- Voir les erreurs en détail : tofu apply

🔴 PROBLÈME : VMs n'exécutent pas cloud-init
SOLUTION :
- Vérifier logs : incus exec VMNAME -- cat /var/log/cloud-init-output.log
- Vérifier fichier YAML syntax (cloud-init/)
- Redémarrer VM : incus restart VMNAME

🔴 PROBLÈME : Ansible ne lance pas playbook
SOLUTION :
- Vérifier logs : incus exec Ansible -- tail -100 /var/log/cloud-init-output.log
- Vérifier repo : incus exec Ansible -- ls -la /home/ubuntu/ansible-repo
- Relancer manuellement :
  incus exec Ansible -- sudo -u ubuntu ansible-playbook \
    /home/ubuntu/ansible-repo/playbook.yml \
    -i /home/ubuntu/ansible-repo/inventory.ini

🔴 PROBLÈME : Docker ne démarre pas
SOLUTION :
- Vérifier services : incus exec Web -- systemctl status docker
- Vérifier logs : incus exec Web -- journalctl -u docker -n 50
- Relancer : incus exec Web -- systemctl restart docker

🔴 PROBLÈME : WordPress inaccessible
SOLUTION :
- Vérifier conteneurs : incus exec Web -- docker ps
- Vérifier logs : incus exec Web -- docker logs wordpress_app
- Vérifier port : incus exec Web -- ss -tlnp | grep 80

================================================================================
ÉTAPE 9 : DESTRUCTION (NETTOYAGE)
================================================================================

9.1 Détruire toute l'infrastructure
-----------------------------------
# Avec confirmation (recommandé)
tofu destroy

# Sans confirmation
tofu destroy -auto-approve

Résultat attendu :
```
...
Destroy complete! Resources have been destroyed.
```

9.2 Si protection activée
--------------------------
Si security_protection_delete = true :

# Modifier terraform.tfvars
# security_protection_delete = false

# Puis détruire
tofu destroy -auto-approve

9.3 Vérifier nettoyage
-----------------------
incus list
# Should be empty or without Ansible/Web VMs

================================================================================
FICHIERS IMPORTANTS
================================================================================

OpenTofu :
- main.tf              : Provider + Config de base
- variables.tf         : Déclaration des variables
- terraform.tfvars     : Valeurs personnalisées (À éditer)
- network.tf           : Réseau OVN
- vm_ansible.tf        : VM Ansible
- vm_web.tf            : VM Web
- outputs.tf           : Outputs

Cloud-init :
- cloud-init/ansible_init.yaml   : Script VM Ansible
- cloud-init/web_init.yaml       : Script VM Web

Ansible :
- ansible/inventory.ini          : Hosts Ansible
- ansible/playbook.yml           : Playbook principale
- ansible/docker-compose.yml     : Docker Compose

Documentation :
- README.md                       : Documentation complète
- terraform.tfvars.example       : Exemple configuration
- EXECUTION.md                   : Ce fichier

================================================================================
RÉSUMÉ DE LA CHAÎNE D'AUTOMATISATION
================================================================================

1. terraform apply
   ↓
2. Terraform crée réseau OVN + VMs
   ↓
3. Cloud-init VM Ansible s'exécute
   ├─ Installe packages (openssh, git, ansible)
   ├─ Génère clé SSH
   ├─ Clone repo GitHub
   └─ Lance playbook Ansible
   ↓
4. Cloud-init VM Web s'exécute
   ├─ Installe openssh
   └─ Configure SSH authorized_keys
   ↓
5. Ansible connecte à VM Web
   ├─ Installe Docker + Docker Compose
   ├─ Crée /opt/wordpress
   ├─ Lance docker-compose up
   ├─ Démarre MySQL + WordPress + phpMyAdmin
   └─ Vérifie services
   ↓
6. WordPress accessible
   └─ http://10.0.100.20

================================================================================
COMMANDES RAPIDES
================================================================================

# Déploiement complet (1 commande)
cd Terraform-TP1 && tofu init && tofu plan && tofu apply -auto-approve && tofu output

# Vérifier état
tofu show

# Vérifier outputs
tofu output

# Vérifier logs
incus exec Ansible -- tail -100 /var/log/cloud-init-output.log
incus exec Web -- docker ps

# Destruction complète
tofu destroy -auto-approve

# Reformatter code
tofu fmt

# Validation
tofu validate

================================================================================
SUPPORT & RESSOURCES
================================================================================

Documentation :
- OpenTofu Incus : https://registry.terraform.io/providers/lxc/incus/latest
- Cloud-init : https://cloud-init.io/
- Ansible : https://docs.ansible.com/
- Docker Compose : https://docs.docker.com/compose/
- WordPress : https://wordpress.org/

Commandes utiles :
- incus list
- incus info VMNAME
- incus exec VMNAME -- bash
- incus logs VMNAME
- terraform plan
- terraform apply
- terraform destroy

================================================================================
FIN DU GUIDE
================================================================================

Vous avez maintenant une infrastructure complète et automatisée !
