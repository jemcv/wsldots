#!/bin/bash

# Stop on error
set -e

echo "Starting setup..."

# Install zsh
echo "Installing zsh..."
sudo apt update
sudo apt install -y zsh

# Change shell to zsh
echo "Changing default shell to zsh..."
chsh -s "$(which zsh)"

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Add zsh plugins
echo "Installing zsh-autosuggestions plugin..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install Starship
echo "Installing Starship..."
curl -sS https://starship.rs/install.sh | sh

# Install Homebrew
echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew packages
echo "Installing brew packages..."
brew install gh php@8.2 mysql redis

# Start brew services
echo "Starting services..."
brew services start php@8.2
brew services start mysql
brew services start redis

# Install Composer
echo "Installing Composer..."

EXPECTED_SIGNATURE=$(curl -s https://composer.github.io/installer.sig)

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

ACTUAL_SIGNATURE=$(php -r "echo hash_file('sha384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    echo "ERROR: Invalid Composer installer signature"
    rm -f composer-setup.php
    exit 1
fi

php composer-setup.php --quiet

echo "Making Composer global..."
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Cleanup
rm -f composer-setup.php

echo "Setup complete."
