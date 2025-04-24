# vault.hcl - Minimal Vault Configuration for Beginners

storage "file" {
    path = "/vault/data"  # Storage directory (persists secrets between restarts)
}

listener "tcp" {
    address     = "0.0.0.0:8200"  # Listen on all network interfaces
    tls_disable = true             # Disable HTTPS (for testing only!)
}

api_addr = "http://181.6.11.2:8200"  # Must match VAULT_ADDR
cluster_addr = "http://181.6.11.2:8201"

# Optional: Enable UI (accessible at http://localhost:8200/ui)
ui = true
