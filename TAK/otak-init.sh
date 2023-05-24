#!/bin/bash
if [ $# -ne 3 ];
then
  echo "Usage: $0 <API_Token> <NETWORK> <JOIN Network 1/0>"
  exit 1
fi

# Store the two arguments in variables
API=$1
NETWORK=$2
JOIN_ZT=$3

# Install ZeroTier
REQUIRED_PKG="zerotier-one"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  curl -s https://install.zerotier.com | sudo bash
else
  echo "$REQUIRED_PKG already installed, moving on."
fi

# Join the ZeroTier Network
folder="/run/zerotier"
if [ ! -d "$folder" ]; then
  mkdir -p "$folder"
  echo "Folder created successfully."
else
  echo "Folder already exists. Will not clone it again, moving on."
fi
if [ ! -f "$folder/joinnetwork" ]; then
  echo "Cloning ZeroTier scripts..."
  wget -P "$folder" "https://raw.githubusercontent.com/afuggetta/ohmr-otak/main/TAK/joinnetwork"
  chmod +x $folder/joinnetwork
  echo "ZeroTier scripts cloned."
fi

if [ "$JOIN_ZT" -eq 1 ]; then
  bash /run/zerotier/joinnetwork --api=$API --network=$NETWORK --member="TAK SERVER"
fi

# Clone and install TAK Server
folder="/home/takuser/tak-server"
if [ ! -d "$folder" ]; then
  git clone https://github.com/afuggetta/tak-server.git /home/takuser/tak-server
  cd $folder
  wget "https://ohmr-tak.nyc3.digitaloceanspaces.com/takserver-docker-4.9-RELEASE-23.zip"
  # ./scripts/setup.sh
else
  echo "Folder already exists. Will not clone it again, moving on."
fi