# OpenTofu + Incus from VS Code (Windows)

This folder shows how to manage Incus instances using OpenTofu (Terraform-compatible) from VS Code on Windows.

## Prereqs
- OpenTofu (`tofu`) installed and on PATH.
- Incus reachable (local or remote). Ensure your client is trusted by the Incus server.
- VS Code Terminal set to PowerShell.

## Authenticate to Incus
Incus uses TLS client certificates by default.

- If your Incus is local and you already use `incus` CLI, it likely trusts your client cert. Verify:

```powershell
incus remote list
incus list
```

- If you need to add your client cert:

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
