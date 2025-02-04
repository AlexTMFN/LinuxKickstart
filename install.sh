#!/bin/bash

# List of packages to install
PACKAGES=("neovim" "curl" "wget" "git" "htop" "lsd" "thefuck" "tmux" "trash-cli" "python" "tldr" "openssh" "qrcp" "gcc" "make" "zip" "unzip" "man")

# List of repositories to clone or update (Format: "repo_url destination_path")
REPOSITORIES=(
    "https://github.com/nvim-lua/kickstart.nvim.git ${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    "https://github.com/tmux-plugins/tpm.git $HOME/.tmux/plugins/tpm"
)

# Detect package manager
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt update && sudo apt install -y"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    INSTALL_CMD="sudo yum install -y"
elif command -v yay &> /dev/null; then
    PKG_MANAGER="yay"
    INSTALL_CMD="yay -S --noconfirm"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -Sy --noconfirm"
elif command -v zypper &> /dev/null; then
    PKG_MANAGER="zypper"
    INSTALL_CMD="sudo zypper install -y"
elif command -v nix-env &> /dev/null; then
    PKG_MANAGER="nix"
    INSTALL_CMD="nix-env -iA nixpkgs"
else
    echo "Unsupported package manager. Exiting."
    exit 1
fi

echo "Detected package manager: $PKG_MANAGER"
echo "Installing packages: ${PACKAGES[*]}"

# Install packages
for package in "${PACKAGES[@]}"; do
    if [[ "$PKG_MANAGER" == "nix" ]]; then
        $INSTALL_CMD."$package"
    else
        $INSTALL_CMD "$package"
    fi
done

echo "Installing or updating Git repositories..."

# Ensure Git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing Git..."
    $INSTALL_CMD git
fi

# Clone or update repositories
for repo in "${REPOSITORIES[@]}"; do
    REPO_URL=$(echo "$repo" | awk '{print $1}')
    DEST_DIR=$(echo "$repo" | awk '{print $2}')

    if [ -d "$DEST_DIR/.git" ]; then
        echo "Updating existing repository at $DEST_DIR..."
        git -C "$DEST_DIR" pull
    else
        echo "Cloning $REPO_URL into $DEST_DIR..."
        git clone "$REPO_URL" "$DEST_DIR"
    fi
done

echo "Installation complete!"

