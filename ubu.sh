$!/bin/bash

echo "Installing lolcat..."
sudo apt-get install lolcat -y

echo "Installing bpytop..." | lolcat
sudo apt-get install bpytop -y | lolcat

# echo "Installing lsd..."
# sudp apt-get install lsd -y | lolcat



