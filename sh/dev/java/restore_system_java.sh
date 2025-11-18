#!/usr/bin/env bash
# restore_system_java.sh
#
# • Re‑set the system‑installed Java as the default (update‑alternatives)
# • Remove any user‑defined JAVA_HOME / PATH edits in your rc file
# • Strip any lingering alias / function named java
# • Tell you what Java is now used
#
# The script does *not* source your rc file – open a new shell (or
# run `source ~/.bashrc` manually) after it finishes if you want the
# changes visible immediately.
#
# Only plain ASCII characters are used.

set -euo pipefail

# ---------- 1.  Make the system Java the default ----------
if command -v update-alternatives >/dev/null 2>&1; then
    echo
    echo "=== Setting the system default Java via update‑alternatives ==="
    sudo update-alternatives --config java
else
    echo
    echo "WARNING: update-alternatives not found – you will need to set java manually."
    echo "On Debian/Ubuntu you can run:"
    echo "    sudo update-alternatives --config java"
fi

# ---------- 2.  Strip user‑level JAVA_HOME / PATH tweaks ----------
# Detect the rc file in use
if [[ -n ${ZSH_VERSION:-} ]]; then
    RC_FILE="$HOME/.zshrc"
elif [[ -n ${BASH_VERSION:-} ]]; then
    RC_FILE="$HOME/.bashrc"
else
    RC_FILE="$HOME/.profile"   # fallback
fi

echo
echo "Cleaning JAVA_HOME / PATH edits from $RC_FILE …"

# Make a backup
cp "$RC_FILE" "${RC_FILE}.bak.restore_system_java"

# Delete lines that export JAVA_HOME or that add JAVA_HOME to PATH
sed -i.bak '/^export[[:space:]]*JAVA_HOME=/d'      "$RC_FILE"
sed -i.bak '/^export[[:space:]]*PATH=.*JAVA_HOME/d' "$RC_FILE"

echo "Removed JAVA_HOME / PATH lines.  Backup kept at ${RC_FILE}.bak.restore_system_java."

# ---------- 3.  Remove any stray alias or function called java ----------
unalias java 2>/dev/null
unset -f java 2>/dev/null

# ---------- 4.  Reset command hash cache ----------
hash -r

# ---------- 5.  Final check ----------
echo
echo "Current Java version:"
java -version

echo
echo "All done – your 'java' command now points to the system default."
echo "If you had a different shell open, close and reopen it (or run 'source $RC_FILE') to see the PATH changes."
