#!/usr/bin/env sh
# Spotifast uninstaller — restores Spotify to stock state, then removes Spotifast.

set -e

spotifast_install="${SPOTIFAST_INSTALL:-$HOME/.spotifast}"
user_data="${SPOTIFAST_CONFIG:-$HOME/.config/spotifast}"

echo ""
echo "=== Spotifast Uninstall ==="

# 1. Restore Spotify before deleting anything (needs the backup it holds)
exe="$spotifast_install/spotifast"
if [ -x "$exe" ]; then
    echo "Restoring Spotify to its original state..."
    "$exe" restore || echo "Restore failed (Spotify may need reinstall)"
elif command -v spotifast >/dev/null 2>&1; then
    spotifast restore || echo "Restore failed (Spotify may need reinstall)"
else
    echo "Spotifast executable not found; skipping restore."
fi

# 2. Remove install folder
if [ -d "$spotifast_install" ]; then
    rm -rf "$spotifast_install"
    echo "Removed install folder."
fi

# 3. Remove user data
if [ -d "$user_data" ]; then
    printf 'Delete user data in %s ? [y/N] ' "$user_data"
    read -r answer < /dev/tty
    case "$answer" in
        y|Y|yes|YES) rm -rf "$user_data"; echo "Removed user data." ;;
        *) echo "Kept user data." ;;
    esac
fi

echo ""
echo "Done. Restart your terminal."
echo "If Spotify shows errors, reinstall Spotify from spotify.com."
