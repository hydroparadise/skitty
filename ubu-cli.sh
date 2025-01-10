#!/bin/bash
# Run: https://raw.githubusercontent.com/hydroparadise/skitty/refs/heads/main/ubu-cli.sh | bash

echo "Installing lolcat..."
sudo apt-get install lolcat -y

echo "Installing git..." | lolcat
sudo apt-get install git -y | lolcat

# https://cli.github.com/manual/gh_auth_login
echo "Installing gh (GitHub Cli)..." | lolcat
sudo apt-get install gh -y | lolcat

echo "Installing bpytop..." | lolcat
sudo apt-get install bpytop -y | lolcat

# echo "Installing lsd..."
# sudp apt-get install lsd -y | lolcat



