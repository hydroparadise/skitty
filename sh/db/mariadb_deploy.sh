#!/usr/bin/env bash
#
#  install-mariadb.sh
#
#  Installs MariaDB 11.8, creates/owns a custom data directory
#  (default: /var/lib/mysql), updates the server config, and starts
#  the daemon.  Everything is idempotent – you can run the script
#  multiple times without side effects.
#
#  ------------------------------------------------------------
#  CONFIGURATION (override by environment variables or
#  interactively prompted if empty)
#
#     MYSQL_DATA_DIR          – where the DB files live (default /var/lib/mysql)
#     MYSQL_ROOT_PASSWORD     – optional root password
#     MARIADB_PACKAGE         – which package to install (default mariadb-server)
#
#  ------------------------------------------------------------
#  USAGE
#  -----
#  # 1. Export the vars you want to force:
#  export MYSQL_DATA_DIR="/mnt/ssd/mysql"
#  export MYSQL_ROOT_PASSWORD="myStrongP@ss"
#
#  # 2. Run the script (as root or with sudo):
#  sudo ./install-mariadb.sh
#
#  ------------------------------------------------------------

set -euo pipefail

# ---------- logging helpers ------------------------------------
log()    { echo -e "\e[32m[+] $*\e[0m"; }
warn()   { echo -e "\e[33m[!] $*\e[0m"; }
error()  { echo -e "\e[31m[✗] $*\e[0m" >&2; exit 1; }

# ---------- check we are root ----------------------------------
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root (or with sudo)."
fi

# ---------- configuration defaults --------------------------------
: "${MYSQL_DATA_DIR:=${MYSQL_DATA_DIR:-}}"
: "${MYSQL_ROOT_PASSWORD:=${MYSQL_ROOT_PASSWORD:-}}"
: "${MARIADB_PACKAGE:=${MARIADB_PACKAGE:-mariadb-server}}"

# ---------- helper: prompt if variable is empty -----------------
prompt_if_empty() {
    local var_name=$1
    local prompt_msg=$2
    local value=${!var_name}
    if [[ -z $value ]]; then
        read -rp "$prompt_msg " value
        export "$var_name=$value"
    fi
}

# ---------- collect missing values -------------------------------
prompt_if_empty MYSQL_DATA_DIR "Enter the path for MariaDB data directory (default /var/lib/mysql): "
# use default if still empty
MYSQL_DATA_DIR=${MYSQL_DATA_DIR:-/var/lib/mysql}

prompt_if_empty MYSQL_ROOT_PASSWORD "Enter a password for MariaDB root user (leave empty to keep it insecure): "

# ---------- step 1: install the MariaDB package (if needed) ------
if dpkg -s "$MARIADB_PACKAGE" >/dev/null 2>&1; then
    log "Package '$MARIADB_PACKAGE' already installed – skipping apt install."
else
    log "Updating package list..."
    apt-get update -qq
    log "Installing package '$MARIADB_PACKAGE'..."
    apt-get install -y --no-install-recommends "$MARIADB_PACKAGE" || error "Failed to install $MARIADB_PACKAGE"
fi

# ---------- step 2: prepare the data directory -------------------
log "Preparing data directory: $MYSQL_DATA_DIR"
mkdir -p "$MYSQL_DATA_DIR" || error "Could not create $MYSQL_DATA_DIR"
chown mysql:mysql "$MYSQL_DATA_DIR" || error "Could not set ownership on $MYSQL_DATA_DIR"
chmod 750 "$MYSQL_DATA_DIR"   || error "Could not set permissions on $MYSQL_DATA_DIR"

# ---------- step 3: update /etc/mysql/mariadb.conf.d/50-server.cnf
CONFIG_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"
if [[ ! -f $CONFIG_FILE ]]; then
    warn "Config file $CONFIG_FILE does not exist – creating a minimal one."
    cat > "$CONFIG_FILE" <<'EOF'
[mysqld]
# Default configuration – minimal.  Your distro may have more.
EOF
fi

# Check if a datadir line already exists
if grep -qE '^\s*datadir\s*=' "$CONFIG_FILE"; then
    current_datadir=$(grep -E '^\s*datadir\s*=' "$CONFIG_FILE" | awk '{print $3}')
    if [[ "$current_datadir" == "$MYSQL_DATA_DIR" ]]; then
        log "Data directory already set to $MYSQL_DATA_DIR – no change needed."
    else
        warn "Overwriting existing datadir ($current_datadir) with $MYSQL_DATA_DIR."
        sed -i "s|^\(\s*datadir\s*=\s*\).*|\1$MYSQL_DATA_DIR|" "$CONFIG_FILE"
    fi
else
    log "Adding datadir line to $CONFIG_FILE."
    echo -e "\n[mysql]\ndatadir = $MYSQL_DATA_DIR" >> "$CONFIG_FILE"
fi

# ---------- step 4: start MariaDB for the first time ----------
log "Starting MariaDB for the first time (initializing system tables)..."
systemctl daemon-reload
systemctl start mariadb

# Wait until mysqld is ready
log "Waiting for MariaDB to start…"
timeout 30 sh -c 'until mysqladmin ping --silent; do sleep 0.5; done' || warn "MariaDB did not become ready within 30 s"

# ---------- step 5: set root password if requested ----------------
if [[ -n $MYSQL_ROOT_PASSWORD ]]; then
    log "Setting root password."
    mysqladmin -u root password "$MYSQL_ROOT_PASSWORD" || error "Failed to set root password"
    # Disable the insecure root login (in case an empty password was left)
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'; FLUSH
PRIVILEGES;"
fi

# ---------- step 6: enable service on boot ---------------------
log "Enabling MariaDB to start at boot."
systemctl enable mariadb

# ---------- final status ----------------------------------------
log "MariaDB installation and configuration complete."
systemctl status mariadb | grep -i "active (running)"
log "Data directory: $MYSQL_DATA_DIR"
log "MariaDB version: $(mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e 'SELECT VERSION();' 2>/dev/null | tail -n1 | tr -d
'[:space:]')"

if [[ -n $MYSQL_ROOT_PASSWORD ]]; then
    log "Root password: ********"
else
    warn "Root user has no password – consider running 'mysql_secure_installation' later."
fi



### How the script works
# | Step | What it does |
# |------|--------------|
# | 1 | Installs the MariaDB Debian package (if not already present). |
# | 2 | Creates/owns the user‑supplied data directory (`/var/lib/mysql` by default). |
# | 3 | Ensures `/etc/mysql/mariadb.conf.d/50-server.cnf` contains a `datadir` line pointing to that directory. |
# | 4 | Starts MariaDB for the first time – this automatically runs `mysqld --initialize-insecure` and writes the system tables into the new data dir. |
# | 5 | Optionally sets the root password if the `MYSQL_ROOT_PASSWORD` variable is supplied. |
# | 6 | Enables the `mariadb` systemd unit to start on boot. |
# | 7 | Prints a quick status report. |
