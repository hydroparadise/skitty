#!/bin/bash

curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
tar -xf google-cloud-cli-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh
gcloud --version && gcloud components update

# Optional
#  $ gcloud components install COMPONENT_ID
#  $ gcloud components remove COMPONENT_ID