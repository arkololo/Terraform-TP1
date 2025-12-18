# --- Project & Storage ---
project      = "HingeEnjoyer4Living2BetterYourself"
storage_pool = "local"

# --- Front VM (Alpine) ---
# Fixed: 512MB RAM, 16GB disk
# Variable: CPU cores
front_cpu = 1

# --- Back VM (Ubuntu Cloud) ---
# Fixed: 32GB disk
# Variable: CPU cores and RAM
back_cpu    = 1
back_memory = "1GB"

# NOTE: ED25519 keys provided by user
ansible_ssh_private_key = <<EOF
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBijjQwTf0qGl4CTRYhM6mn4fiJmAe/66RPsjy+jaRd4gAAAIjJCgV6yQoF
egAAAAtzc2gtZWQyNTUxOQAAACBijjQwTf0qGl4CTRYhM6mn4fiJmAe/66RPsjy+jaRd4g
AAAEAK1YhQhQ2PSJY5NT+SFIQmbs7GPly2zEQq9fz4crgRXWKONDBN/SoaXgJNFiEzqafh
+ImYB7/rpE+yPL6NpF3iAAAAAAECAwQF
-----END OPENSSH PRIVATE KEY-----
EOF

ansible_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKONDBN/SoaXgJNFiEzqafh+ImYB7/rpE+yPL6NpF3i"

