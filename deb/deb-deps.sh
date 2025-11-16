#!/bin/bash

# Generate and set locale
echo "Configuring locale..."
sudo apt update -qq
sudo apt install -y locales
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install packages
echo "Installing packages..."
sudo apt install -y \
    dunst \
    nano \
    stow \
    kitty \
    fzf \
    yazi \
    ripgrep \
    bat \
    neovim \
    btop \
    nala \
    git \
    wget \
    curl \
    zsh \
    build-essential

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

# Install GitHub CLI
echo "Installing GitHub CLI..."
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

echo "GitHub CLI installed!"

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
cd "$HOME/stow/deb" || exit 1

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
echo "Shell changed to zsh. Please log out and back in for changes to take effect."
