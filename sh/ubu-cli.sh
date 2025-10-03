#!/bin/bash
# Run: https://raw.githubusercontent.com/hydroparadise/skitty/refs/heads/main/ubu-cli.sh | bash

echo "Installing lolcat..."
sudo apt-get -q install lolcat -y

sudo apt-get update -y | lolcat

echo "Installing git..." | lolcat
sudo apt-get install git -y | lolcat

# https://cli.github.com/manual/gh_auth_login
echo "Installing gh (GitHub Cli)..." | lolcat
sudo apt-get install gh -y | lolcat

echo "Installing bpytop..." | lolcat
sudo apt-get install bpytop -y | lolcat

echo "Installing tree..." | lolcat
sudo apt-get install tree -y | lolcat

echo "Installing python3..." | lolcat
sudo apt-get install python3 -y | lolcat

echo "Installing pip..." | lolcat
sudo apt-get install pip -y | lolcat

echo "Installing python3.12-venv..." | lolcat
sudo apt install python3.12-venv -y | lolcat
python3 -m venv .venv
source .venv/bin/activate

# Havent't yet sorted out synthshell and powerline for ssh sessions

# echo "Installing fonts-powerline..." | lolcat
# sudo apt-get install fonts-powerline -y | lolcat

# echo "Installing powerline-status..." | lolcat
# pip install powerline-status | lolcat

# git clone https://github.com/b-ryan/powerline-shell
# cd powerline-shell
# sudo python3 setup.py install

# function _update_ps1() {
#    PS1=$(powerline-shell $?)
# }

# if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
#    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
# fi

# git clone --recursive https://github.com/andresgongora/synth-shell.git | lolcat
# cd synth-shell
# ./setup.sh | lolcat
 
# echo "Installing lsd..." | lolcat
# sudo apt-get install lsd -y | lolcat



