#!/bin/bash

# Generate and set locale to prevent perl warnings
echo "Configuring locale..."
sudo sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sudo locale-gen
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

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
    yazi \
    neovim \
    ripgrep \
    fzf \
    bat \
    btop \
    wget \
    curl \
    zsh \
    base-devel

echo "Installation complete!"

# Install LazyVim
echo "Installing LazyVim..."
if [ -d "$HOME/.config/nvim" ]; then
    echo "Neovim config directory already exists, skipping LazyVim installation..."
else
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
    echo "LazyVim installed!"
fi

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
cd "$HOME/stow/arch" || exit 1

for dir in */; do
    if [ -d "$dir" ]; then
        dirname="${dir%/}"
        echo "Stowing $dirname..."
        stow -t "$HOME" "$dirname"
    fi
done

echo "Dotfiles setup complete!"

# Change default shell to zsh
echo "Changing default shell to zsh..."
chsh -s /usr/bin/zsh
