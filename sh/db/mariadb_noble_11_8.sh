#!/usr/bin/env bash
#
#  install-mariadb.sh
#
#  Installs MariaDB 11.8 from the official MariaDB repository
#  on Linux Mint 22 (Ubuntu 24.04 “noble”).
#
#  ------------------------------------------------------
#  NOTE
#  ------------------------------------------------------
#  * The script is idempotent – running it again will
#    simply skip already‑completed steps.
#  * It requires sudo privileges (it will call `sudo`).
#  * It keeps the repository list in /etc/apt/sources.list.d/mariadb.sources
#  * The key is stored in /etc/apt/keyrings/mariadb-keyring.pgp
#  * If you want the “old one‑line” APT format, use
#    /etc/apt/sources.list.d/mariadb.list instead.
#  * Debug‑symbol packages (‑dbgsym) are not installed.
#  * Source packages are not enabled by default.
#  ------------------------------------------------------
#  Check OS: cat /etc/os-release

set -euo pipefail

# ------------------------------------------------------
# Helper functions
# ------------------------------------------------------
log()    { echo -e "\e[32m[+] $*\e[0m"; }
warn()   { echo -e "\e[33m[!] $*\e[0m"; }
error()  { echo -e "\e[31m[✗] $*\e[0m" >&2; exit 1; }

# ------------------------------------------------------
# Check if script is run as root (sudo)
# ------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root (or with sudo)."
fi

log "Detecting OS codename …"
# Grab the variables from /etc/os-release – it defines UBUNTU_CODENAME
# (Linux‑Mint sets this field even when VERSION_CODENAME is something else).
source /etc/os-release || error "Could not read /etc/os-release"

# Prefer UBUNTU_CODENAME, fall back to VERSION_CODENAME
CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME}}"

log "  • Detected Ubuntu codename: $CODENAME"

if [[ "$CODENAME" != "noble" ]]; then
    error <<EOF
The MariaDB 11.8 repository that this script adds is built for
Ubuntu 24.04 (codename **noble**).  Your system reports the
codename '$CODENAME', which is not compatible with the repo
definition in /etc/apt/sources.list.d/mariadb.sources.

If you are on a different Ubuntu release (e.g. “jammy”, “focal”,
or an older Linux‑Mint release) you have two options:

  • Edit the repo file that the script creates and replace the
    line `Suites: noble` with the codename that matches your
    distribution.  Then re‑run the script.

  • Use a MariaDB version that is published for your codename
    instead of 11.8.

Because of the mismatch the install would fail at the very first
`apt-get update` after adding the repo, so we abort early.
EOF
fi


# ------------------------------------------------------
# Install prerequisites (apt‑transport‑https + curl)
# ------------------------------------------------------
log "Ensuring apt‑transport‑https and curl are installed..."
apt-get update -qq
apt-get install -y --no-install-recommends apt-transport-https curl || error "Failed to install prerequisites"

# ------------------------------------------------------
# Create keyring directory (idempotent)
# ------------------------------------------------------
KEYRING_DIR="/etc/apt/keyrings"
KEYRING_FILE="$KEYRING_DIR/mariadb-keyring.pgp"
mkdir -p "$KEYRING_DIR"

# ------------------------------------------------------
# Import the MariaDB GPG key (skip if already present)
# ------------------------------------------------------
if [[ ! -s "$KEYRING_FILE" ]]; then
    log "Downloading MariaDB GPG key..."
    curl -fsSL -o "$KEYRING_FILE" \
         'https://mariadb.org/mariadb_release_signing_key.pgp' || error "Failed to download key"
else
    log "MariaDB key already present – skipping download."
fi

# ------------------------------------------------------
# Create the repository file (idempotent)
# ------------------------------------------------------
REPO_FILE="/etc/apt/sources.list.d/mariadb.sources"
cat > "$REPO_FILE" <<'EOF'
# MariaDB 11.8 repository list - created 2025-10-08 10:16 UTC
# https://mariadb.org/download/
X-Repolib-Name: MariaDB
Types: deb
# deb.mariadb.org is a dynamic mirror if your preferred mirror goes offline. See https://mariadb.org/mirrorbits/ for details.
# URIs: https://deb.mariadb.org/11.8/ubuntu
URIs: https://mirrors.accretive-networks.net/mariadb/repo/11.8/ubuntu
Suites: noble
Components: main main/debug
Signed-By: /etc/apt/keyrings/mariadb-keyring.pgp
EOF

log "Repository file created at $REPO_FILE"

# ------------------------------------------------------
# Update package lists
# ------------------------------------------------------
log "Running 'apt-get update'..."
apt-get update -qq

# ------------------------------------------------------
# Check if MariaDB is already installed
# ------------------------------------------------------
if dpkg -s mariadb-server >/dev/null 2>&1; then
    log "MariaDB is already installed – skipping installation."
else
    # ------------------------------------------------------
    # nstall MariaDB server
    # ------------------------------------------------------
    log "Installing MariaDB 11.8 server..."
    apt-get install -y mariadb-server || error "MariaDB installation failed"
fi

# ------------------------------------------------------
# Final status
# ------------------------------------------------------
log "MariaDB 11.8 is installed and ready to use."
log "You can verify by running: systemctl status mariadb"
log "If you need to enable the service at boot: systemctl enable mariadb"

# ------------------------------------------------------
# Optional: show the MariaDB version
# ------------------------------------------------------
mariadb --version
