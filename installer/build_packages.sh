#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PANEL_ROOT="$(cd "$DIR/.." && pwd)"
UPLOAD_DIR="$DIR/UPLOAD_TO_SUBDOMAIN"
AI_SRC_DIR="$DIR/algopanel-ai"

# If extracted AI source does not exist, extract it from tracked archive
if [ ! -d "$AI_SRC_DIR" ]; then
    echo "Extracting algopanel-ai sources..."
    mkdir -p "$AI_SRC_DIR"
    tar -xzf "$DIR/algopanel-ai-src.tar.gz" -C "$AI_SRC_DIR"
fi

# Clean and recreate the final ready-to-upload folder
rm -rf "$UPLOAD_DIR"
mkdir -p "$UPLOAD_DIR/downloads"

echo "=== 1. Packaging AlgoPanel Source (algopanel-stable.tar.gz) ==="
rm -rf /tmp/algopanel_pkg
mkdir -p /tmp/algopanel_pkg/ispconfig3_install
rsync -a --exclude='.git' --exclude='.docker' --exclude='docker-compose.yml' --exclude='installer' "$PANEL_ROOT/" /tmp/algopanel_pkg/ispconfig3_install/
cd /tmp/algopanel_pkg
tar -czf "$UPLOAD_DIR/downloads/algopanel-stable.tar.gz" ispconfig3_install
cp "$UPLOAD_DIR/downloads/algopanel-stable.tar.gz" "$UPLOAD_DIR/downloads/algopanel-develop.tar.gz"
rm -rf /tmp/algopanel_pkg

echo "=== 2. Packaging AlgoPanel Auto-Installer (algopanel-ai.tar.gz) ==="
cd "$AI_SRC_DIR"
tar -czf "$UPLOAD_DIR/downloads/algopanel-ai.tar.gz" *

echo "=== 3. Copying helper files & Entrypoint ==="
cp "$DIR/auto_update_phpmyadmin.sh" "$UPLOAD_DIR/downloads/"
cp "$DIR/install.sh" "$UPLOAD_DIR/install.sh"
cp "$DIR/install.sh" "$UPLOAD_DIR/index.html"

cat << 'HTACCESS' > "$UPLOAD_DIR/.htaccess"
<Files "index.html">
    ForceType text/plain
</Files>
<Files "install.sh">
    ForceType text/plain
</Files>
HTACCESS

echo "--------------------------------------------------------"
echo "SUCCESS! Everything is ready in:"
echo "$UPLOAD_DIR"
echo "--------------------------------------------------------"
