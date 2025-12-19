================================================================================
COMMANDES EXACTES À EXÉCUTER - COPY/PASTE
================================================================================

⚠️ AVANT DE COMMENCER : Avoir OpenTofu installé
   https://opentofu.org/docs/intro/install/

================================================================================
ÉTAPE 1 : NAVIGUER AU RÉPERTOIRE
================================================================================

# Windows CMD
cd c:\Users\Tomy Rulliat\Desktop\CPE-cours\2emeAnnee\DevOps\DEVOPS-2\Terraform-github\Terraform-TP1

# Windows PowerShell
cd 'c:\Users\Tomy Rulliat\Desktop\CPE-cours\2emeAnnee\DevOps\DEVOPS-2\Terraform-github\Terraform-TP1'

# Linux/Mac Bash
cd ~/Desktop/CPE-cours/2emeAnnee/DevOps/DEVOPS-2/Terraform-github/Terraform-TP1

================================================================================
ÉTAPE 2 : VÉRIFIER OPENTOFU EST INSTALLÉ
================================================================================

tofu version

# Résultat attendu :
# OpenTofu v1.x.x on ...

================================================================================
ÉTAPE 3 : INITIALISER OPENTOFU
================================================================================

tofu init

# Résultat attendu :
# Initializing the backend...
# Successfully configured the backend "local"!
# Initializing provider plugins...
# ...
# OpenTofu has been successfully initialized!

================================================================================
ÉTAPE 4 : VALIDER LA CONFIGURATION
================================================================================

tofu validate

# Résultat attendu :
# Success! The configuration is valid.

================================================================================
ÉTAPE 5 : VÉRIFIER LE PLAN (CE QUI VA ÊTRE CRÉÉ)
================================================================================

tofu plan

# Résultat attendu :
# Plan: 4 to add, 0 to change, 0 to destroy
# 
# Changes to Outputs:
#   + ansible_vm_ip
#   + ansible_vm_name
#   + ansible_vm_status
#   + infrastructure_summary
#   + ssh_access
#   + web_vm_ip
#   + web_vm_name
#   + web_vm_status
#   + wordpress_access
#   + wordpress_url
#   + wordpress_url_admin

================================================================================
ÉTAPE 6 : DÉPLOYER (CRÉER INFRASTRUCTURE + AUTOMATISER)
================================================================================

tofu apply -auto-approve

# ⏱️ ATTENDRE ~2-3 minutes
# Les VMs vont se créer et cloud-init va s'exécuter automatiquement

# Résultat attendu :
# Apply complete! Resources have been created.
# 
# Outputs:
#   ansible_execution_note = "Ansible playbook should be executing..."
#   ansible_vm_ip = "10.0.100.10"
#   ...
#   wordpress_access = {
#     "admin_url" = "http://10.0.100.20/wp-admin"
#     "phpmyadmin_url" = "http://10.0.100.20:8080"
#     "url" = "http://10.0.100.20"
#   }

================================================================================
ÉTAPE 7 : VOIR TOUS LES OUTPUTS
================================================================================

tofu output

# Cela affiche :
# - IPs des VMs
# - URLs WordPress + Admin + phpMyAdmin
# - Commandes SSH
# - Notes de sécurité

================================================================================
ÉTAPE 8 : ATTENDRE QUE TOUT SOIT PRÊT (2-5 MINUTES)
================================================================================

# Vérifier que les services Docker sont en cours d'exécution
incus exec Web -- docker ps

# Résultat attendu (après quelques minutes) :
# CONTAINER ID   IMAGE       COMMAND                  STATUS          PORTS
# xxxxx          mysql:8.0   "docker-entrypoint.s..." Up ...         3306/tcp
# xxxxx          wordpress   "docker-entrypoint.p..." Up ...         0.0.0.0:80->80/tcp
# xxxxx          phpmyadmin  "/docker-entrypoint...." Up ...         0.0.0.0:8080->80/tcp

================================================================================
ÉTAPE 9 : ACCÉDER À WORDPRESS
================================================================================

# Dans le navigateur, ouvrir :
http://10.0.100.20

# Devrait afficher : WordPress installation screen

# Admin panel :
http://10.0.100.20/wp-admin

# phpMyAdmin (gestion base de données) :
http://10.0.100.20:8080

================================================================================
ÉTAPE 10 : VÉRIFIER LES LOGS (OPTIONNEL - TROUBLESHOOTING)
================================================================================

# Logs cloud-init VM Ansible
incus exec Ansible -- tail -100 /var/log/cloud-init-output.log

# Logs playbook Ansible
incus exec Ansible -- tail -50 /tmp/ansible-playbook.log

# Logs Docker
incus exec Web -- docker logs wordpress_app

# Vérifier connectivity
incus exec Ansible -- ping -c 3 10.0.100.20

================================================================================
ÉTAPE 11 : ACCÈS SSH (OPTIONNEL)
================================================================================

# Voir les commandes SSH exactes
tofu output ssh_access

# Résultat (exemple) :
# ssh_access = {
#   "ansible_vm" = "ssh -i ~/.ssh/id_ed25519 ubuntu@10.0.100.10"
#   "web_vm"     = "ssh -i ~/.ssh/id_ed25519 debian@10.0.100.20"
# }

# Se connecter à VM Ansible
ssh -i ~/.ssh/id_ed25519 ubuntu@10.0.100.10

# Se connecter à VM Web
ssh -i ~/.ssh/id_ed25519 debian@10.0.100.20

# Via Incus directement
incus exec Ansible -- bash
incus exec Web -- bash

================================================================================
ÉTAPE 12 : NETTOYER - SUPPRIMER TOUTE L'INFRASTRUCTURE
================================================================================

# ⚠️ ATTENTION : Cela supprime TOUT (VMs, réseau, données)

# Détruire avec confirmation
tofu destroy

# Ou sans confirmation
tofu destroy -auto-approve

# Résultat attendu :
# Destroy complete! Resources have been destroyed.

# Vérifier qu'il n'y a plus de VMs
incus list

================================================================================
COMMANDES COMPLÈTES - À COPIER COLLER
================================================================================

# DÉPLOIEMENT COMPLET (UNE SEULE COMMANDE)
cd c:\Users\Tomy Rulliat\Desktop\CPE-cours\2emeAnnee\DevOps\DEVOPS-2\Terraform-github\Terraform-TP1 && tofu init && tofu plan && tofu apply -auto-approve && tofu output

# TEST RAPIDE - Vérifier que tout fonctionne
tofu plan && tofu apply -auto-approve && tofu output wordpress_access

# DESTRUCTION COMPLÈTE
tofu destroy -auto-approve

# REFORMATTER LES FICHIERS
tofu fmt -recursive

# REVALIDER APRÈS MODIFICATION
tofu validate

================================================================================
RACCOURCIS UTILES
================================================================================

# Voir l'état actuel
tofu show

# Voir les outputs (IPs, URLs)
tofu output

# Voir un output spécifique
tofu output wordpress_access
tofu output ssh_access
tofu output infrastructure_summary

# Rafraîchir l'état
tofu refresh

# Détail d'une ressource
tofu show incus_instance.ansible
tofu show incus_instance.web

# Plan d'une destruction (avant destroy)
tofu plan -destroy

================================================================================
SI ERREUR - COMMANDES DE NETTOYAGE
================================================================================

# Si terraform.lock est corrompu
rm .terraform.lock.hcl

# Si .terraform est corrompu
rm -r .terraform

# Puis réinitialiser
tofu init

# Voir les erreurs détaillées (très verbeux)
tofu apply -auto-approve -no-color > deploy.log 2>&1

# Relancer après erreur
tofu apply -auto-approve

================================================================================
STATUT DU DÉPLOIEMENT
================================================================================

# Voir les VMs créées
incus list

# Voir les réseau OVN créés
incus network list

# Voir les détails d'une VM
incus info Ansible
incus info Web

# Voir les logs d'une VM
incus logs Ansible
incus logs Web

# Voir les interfaces réseau
incus exec Web -- ip addr show
incus exec Ansible -- ip addr show

================================================================================
FIN - BRAVO ! 🎉
================================================================================

Votre infrastructure est maintenant :
✓ Entièrement déployée
✓ Automatisée (Cloud-init + Ansible)
✓ WordPress accessible
✓ Prête pour développement/production

Prochaines étapes :
1. Configurer WordPress (admin)
2. Ajouter du contenu
3. Personnaliser selon vos besoins

================================================================================
