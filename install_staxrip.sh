#!/usr/bin/env bash
# ==============================================================================
# StaxRip Linux Installer (Wine)
# ==============================================================================

set -e

PREFIX_DIR="$HOME/.wine-staxrip"
STAXRIP_DIR="$PREFIX_DIR/drive_c/StaxRip"
DESKTOP_FILE="$HOME/.local/share/applications/staxrip.desktop"

export WINEPREFIX="$PREFIX_DIR"
export WINEARCH="win64"
export WINEDEBUG="-all"

echo "==> Checking required tools..."
for cmd in wine winetricks 7z curl; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: '$cmd' is not installed."
        exit 1
    fi
done

# Wine configuration
echo "==> Initializing Wine prefix..."
wineboot -u
wineserver -w || true

echo "==> Configuring Windows version..."
winetricks -q win10

# Removes Wine Mono as it causes StaxRip to crash.
echo "==> Evicting Wine Mono..."
winetricks -q remove_mono || true

echo "==> Installing Core Dependencies..."
# dotnet48: Fixes Regex/UI parsing crashes.
# vcrun2022: Required for C++ encoders and VapourSynth.
# corefonts: Fixes missing text fonts.
# dxvk: Bypasses OpenGL/libEGL hardware crashes (atleast I hoped for that).
winetricks -q dotnet48 vcrun2022 corefonts dxvk

# Fetch latest Staxrp release.
# Dev Note: This may need to be updated in the future when newer StaxRip releases are found to not be working.
echo "==> Fetching latest StaxRip release..."
LATEST_URL=$(curl -s https://api.github.com/repos/staxrip/staxrip/releases/latest | grep "browser_download_url" | grep -i "x64.7z" | grep -vi "exe" | head -n 1 | cut -d '"' -f 4)

if [ -z "$LATEST_URL" ]; then
    echo "Error: Could not determine download URL."
    exit 1
fi

echo "==> Downloading StaxRip..."
mkdir -p "$PREFIX_DIR/downloads"
ARCHIVE_NAME=$(basename "$LATEST_URL")
curl -L -# -o "$PREFIX_DIR/downloads/$ARCHIVE_NAME" "$LATEST_URL"

echo "==> Extracting StaxRip..."
mkdir -p "$STAXRIP_DIR"
7z x -y "$PREFIX_DIR/downloads/$ARCHIVE_NAME" -o"$STAXRIP_DIR" > /dev/null

echo "==> Generating Desktop Shortcut..."
mkdir -p "$HOME/.local/share/applications"

# Dynamically map the extracted structure
ACTUAL_EXE_PATH=$(find "$STAXRIP_DIR" -name "StaxRip.exe" | head -n 1)
ACTUAL_EXE_DIR=$(dirname "$ACTUAL_EXE_PATH")

# Find Staxrip's bundled Python and convert it to a Windows path for injection
PY_DLL=$(find "$ACTUAL_EXE_DIR" -name "python3*.dll" | head -n 1)
PY_DIR=$(dirname "$PY_DLL")
# Double-escape the backslashes so the .desktop file reads them correctly
WIN_PY_PATH=$(winepath -w "$PY_DIR" | sed 's/\\/\\\\\\\\/g')

# Writes .desktop file to start menu
cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=StaxRip
Comment=Advanced Video Encoding GUI
Exec=sh -c 'export WINEPREFIX="\$HOME/.wine-staxrip"; export WINEDLLOVERRIDES="wbemprox=d"; export WINEPATH="$WIN_PY_PATH"; cd "$ACTUAL_EXE_DIR" && wine StaxRip.exe'
Type=Application
Terminal=false
StartupNotify=true
Icon=wine
Categories=AudioVideo;Video;AudioVideoEditing;
EOF

chmod +x "$DESKTOP_FILE"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

# Cleans up downloads folder in Wine prefix
echo "==> Cleaning up..."
rm -rf "$PREFIX_DIR/downloads"
echo "Installation Complete!"
