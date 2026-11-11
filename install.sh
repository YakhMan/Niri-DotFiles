#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Niri + Quickshell Dotfiles Installer ${NC}"
echo -e "${BLUE}========================================${NC}"

# 1. INSTALL DEPENDENCIES FIRST
echo -e "\n${YELLOW}[1/4] Installing dependencies...${NC}"
OFFICIAL_PKGS="quickshell awww imagemagick hyprlock mako jq kitty fish"
AUR_PKGS="wallpick-git"

if command -v yay &> /dev/null; then
    HELPER="yay"
elif command -v paru &> /dev/null; then
    HELPER="paru"
else
    HELPER=""
fi

if [ -n "$HELPER" ]; then
    echo "  - AUR helper detected ($HELPER). Installing packages..."
    $HELPER -S --needed $OFFICIAL_PKGS $AUR_PKGS
else
    echo "  - No AUR helper found. Installing official Arch packages via pacman..."
    sudo pacman -S --needed $OFFICIAL_PKGS
    echo -e "\n${RED}ACTION REQUIRED:${NC} You must manually install: $AUR_PKGS"
    echo "  (e.g., git clone https://aur.archlinux.org/wallpick-git.git && cd wallpick-git && makepkg -si)"
fi

# 2. Backup existing configs
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
echo -e "\n${YELLOW}[2/4] Backing up existing configurations...${NC}"
mkdir -p "$BACKUP_DIR"
CONFIG_DIRS="niri quickshell kitty mako hypr wallpick fish"
for dir in $CONFIG_DIRS; do
    if [ -d "$HOME/.config/$dir" ]; then
        cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
        echo "  - Backed up ~/.config/$dir"
    fi
done

# 3. Copy configuration files
echo -e "\n${YELLOW}[3/4] Copying configuration files...${NC}"
mkdir -p "$HOME/.config"
if [ -d "config" ]; then
    cp -r config/* "$HOME/.config/"
    echo -e "  - Configs successfully copied."
else
    echo -e "${RED}  - Error: 'config' folder not found!${NC}"
fi

# 4. Install Custom Scripts & Wallpapers
echo -e "\n${YELLOW}[4/4] Installing scripts and wallpapers...${NC}"
mkdir -p "$HOME/.local/bin"
if [ -d "local/bin" ]; then
    cp local/bin/* "$HOME/.local/bin/"
    chmod +x "$HOME/.local/bin/"*.sh
    echo -e "  - Scripts installed."
fi

mkdir -p "$HOME/Pictures/wallpapers"
if [ -d "wallpapers" ] && [ "$(ls -A wallpapers)" ]; then
    cp wallpapers/* "$HOME/Pictures/wallpapers/"
    echo -e "  - Wallpapers copied."
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}   Installation Complete!               ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Please log out and log back into Niri to apply the changes."
echo -e "Backup stored in: ${BLUE}$BACKUP_DIR${NC}\n"