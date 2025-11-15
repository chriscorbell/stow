#!/bin/bash

# Update package lists
echo "Updating package database..."
sudo pacman -Syu --noconfirm

# Install packages
echo "Installing packages..."
sudo pacman -S --noconfirm \
    fastfetch \
    dunst \
    nano \
    stow \
    kitty \
    ttf-jetbrains-mono-nerd \
    git \
    github-cli \
    wget \
    curl \
    base-devel

echo "Installation complete!"

# Install yay AUR helper
echo "Installing yay..."
if command -v yay &> /dev/null; then
    echo "yay is already installed, skipping..."
else
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
    echo "yay installed!"
fi

# Configure git
echo "Configuring git..."
git config --global user.name "chriscorbell"
git config --global user.email "88693878+chriscorbell@users.noreply.github.com"
git config --global init.defaultBranch main

# Authenticate with GitHub
echo "Authenticating with GitHub..."
gh auth login
gh auth setup-git

echo "Git configuration complete!"

# Clone dotfiles repository
echo "Cloning dotfiles repository..."
if [ -d "$HOME/stow" ]; then
    echo "Directory ~/stow already exists, skipping clone..."
else
    git clone https://github.com/chriscorbell/stow "$HOME/stow"
fi

# Run stow for each directory in the repo
echo "Setting up dotfiles with stow..."
cd "$HOME/stow" || exit 1

for dir in */; do
    if [ -d "$dir" ]; then
        dirname="${dir%/}"
        echo "Stowing $dirname..."
        stow "$dirname"
    fi
done

echo "Dotfiles setup complete!"
