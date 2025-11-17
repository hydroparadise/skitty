#!/bin/bash

# Prereq
echo "Curl is required"
echo "sudo apt install curl"

# Need to figure out if version will always be required
echo "Installing NVM to install NPM"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

nvm install --lts