#!/usr/bin/env bash
#
#  uninstall-mariadb.sh
#
#  Removes MariaDB 11.8 (the exact package installed by
#  `install-mariadb.sh` in the question) from a Linux Mint 22 / Ubuntu 24.04
#  system.  The script is **idempotent** – running it again will simply
#  skip steps that have already been completed.
#
#  -------------------------------------------------------------------------
#  IMPORTANT
#  -------------------------------------------------------------------------
#  * The script must be run as root (or via sudo).
#  * It stops and disables the `mariadb` systemd service.
#  * It purges the MariaDB packages *and* the package‑configuration
#    files (unless you set PURGE_DATA=1 to remove the data directory).
#  * It removes the APT repository file and the GPG keyring that were
#    added by the install script.
#  * It performs an `apt-get update` at the end to clean the local
#    package cache.
#  * The script is deliberately conservative – if the MariaDB package
#    is not present it will simply report that and exit cleanly.
#  -------------------------------------------------------------------------

set -euo pipefail

# -------------------------------------------------------------------------
# Helper functions – colourised output
# -------------------------------------------------------------------------
log()    { echo -e "\e[32m[+] $*\e[0m"; }
warn()   { echo -e "\e[33m[!] $*\e[0m"; }
error()  { echo -e "\e[31m[✗] $*\e[0m" >&2; exit 1; }

# -------------------------------------------------------------------------
# Check that we are running as root
# -------------------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root (or with sudo)."
fi

log "Uninstalling MariaDB 11.8 …"

# -------------------------------------------------------------------------
# Stop & disable the service
# -------------------------------------------------------------------------
if systemctl is-active --quiet mariadb; then
    log "Stopping the MariaDB service…"
    systemctl stop mariadb
else
    warn "MariaDB service is already stopped."
fi

if systemctl is-enabled --quiet mariadb; then
    log "Disabling MariaDB from starting at boot…"
    systemctl disable mariadb
else
    warn "MariaDB is already disabled."
fi

# -------------------------------------------------------------------------
# 1️⃣  Purge the MariaDB packages
# -------------------------------------------------------------------------
# The official install script pulls in the following:
#   mariadb-server
#   mariadb-client   (pulled in by mariadb-server)
#   mariadb-common   (pulled in by mariadb-server)
#
# We purge all of them to delete configuration files and
# binaries.  If the user *wanted* to keep their data directory
# they can set PURGE_DATA=0 (default).
#
# Example usage:
#   PURGE_DATA=1 ./uninstall-mariadb.sh   # also delete /var/lib/mysql*
#
PURGE_DATA=${PURGE_DATA:-0}

if dpkg -s mariadb-server >/dev/null 2>&1; then
    log "Purging MariaDB packages…"
    apt-get purge -y mariadb-server mariadb-client mariadb-common || error "Failed to purge MariaDB packages"
    apt-get autoremove -y
else
    warn "MariaDB packages not found – skipping purge."
fi

# -------------------------------------------------------------------------
# (Optional) Delete the data directory
# -------------------------------------------------------------------------
if [[ $PURGE_DATA -eq 1 ]]; then
    if [[ -d /var/lib/mysql ]]; then
        log "Removing MariaDB data directory /var/lib/mysql …"
        rm -rf /var/lib/mysql
    else
        warn "Data directory /var/lib/mysql already missing."
    fi
else
    warn "PURGE_DATA=0 – keeping the data directory."
fi

# -------------------------------------------------------------------------
# Remove the APT repository file
# -------------------------------------------------------------------------
REPO_FILE="/etc/apt/sources.list.d/mariadb.sources"
if [[ -f $REPO_FILE ]]; then
    log "Removing repository file $REPO_FILE …"
    rm -f "$REPO_FILE"
else
    warn "Repository file $REPO_FILE not found – skipping removal."
fi

# -------------------------------------------------------------------------
# Remove the GPG keyring
# -------------------------------------------------------------------------
KEYRING_DIR="/etc/apt/keyrings"
KEYRING_FILE="$KEYRING_DIR/mariadb-keyring.pgp"

if [[ -s $KEYRING_FILE ]]; then
    log "Removing keyring $KEYRING_FILE …"
    rm -f "$KEYRING_FILE"
else
    warn "Keyring file $KEYRING_FILE not found – skipping removal."
fi

# -------------------------------------------------------------------------
# Update the package cache
# -------------------------------------------------------------------------
log "Running 'apt-get update' to refresh the local cache…"
apt-get update -qq

# -------------------------------------------------------------------------
# Final status
# -------------------------------------------------------------------------
log "MariaDB 11.8 has been removed."
log "You can verify that the service is gone with:"
log "   systemctl status mariadb"
log "or with the APT query:"
log "   dpkg -s mariadb-server"
