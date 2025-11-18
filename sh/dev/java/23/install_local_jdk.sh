#!/usr/bin/env bash
# install_jdk23.sh
# --------------------------------------------
# Install OpenJDK 23.0.2 into an XDG data dir.
# The system Java remains unchanged.
# --------------------------------------------
# This script uses only plain ASCII characters – no fancy quotes,
# no em‑dashes, no non‑ASCII symbols.

set -euo pipefail

# ----------------- Configuration -----------------
JDK_URL="https://download.java.net/java/GA/jdk23.0.2/6da2a6609d6e406f85c491fcb119101b/7/GPL/openjdk-23.0.2_linux-x64_bin.tar.gz"

# XDG defaults – fall back to ~/.local/... if not set
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

TARGET_DIR="$XDG_DATA_HOME/java-23.0.2"

echo "OpenJDK 23.0.2 (linux-x64) will be downloaded to:"
echo "  $TARGET_DIR/jdk23.0.2"

read -p "Press ENTER to install to the default path, or type an alternate directory: " alt
TARGET_DIR=${alt:-$TARGET_DIR}

mkdir -p "$TARGET_DIR" || { echo "Error: cannot create $TARGET_DIR" >&2; exit 1; }

# ------------- Check for required tools -------------
for cmd in curl tar; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "Error: $cmd not found" >&2; exit 1; }
done

# ----------------- Download -----------------
TARBALL="$TARGET_DIR/openjdk-23.0.2_linux-x64_bin.tar.gz"
echo
echo "Downloading JDK ..."
curl -L "$JDK_URL" -o "$TARBALL"

# ----------------- Extract -----------------
echo "Extracting ..."
tar -xzf "$TARBALL" -C "$TARGET_DIR"

# The tarball extracts into jdk-23.0.2
EXTRACTED_DIR="$TARGET_DIR/jdk-23.0.2"
NEW_DIR="$TARGET_DIR/jdk23.0.2"

if [[ -d $EXTRACTED_DIR ]]; then
    mv "$EXTRACTED_DIR" "$NEW_DIR"
else
    echo "Warning: expected directory $EXTRACTED_DIR not found after extraction" >&2
fi

echo
echo "JDK successfully installed to:"
echo "  $NEW_DIR"
echo

echo "To use this JDK in the current shell, run:"
echo "  export JAVA_HOME=\"$NEW_DIR\""
echo "  export PATH=\"$JAVA_HOME/bin:\$PATH\""
echo
echo "You can add those two lines to your ~/.bashrc or ~/.zshrc to make it permanent."
echo
echo "Done."
