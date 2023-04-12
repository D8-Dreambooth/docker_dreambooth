#!/bin/bash

echo "Dreambooth Container Started"

# fetch launch.sh from GitHub and save to /workspace/launch.sh
curl -L https://raw.githubusercontent.com/D8-Dreambooth/docker_dreambooth/main/launch.sh -o /workspace/launch.sh

# fetch relauncher.py from GitHub and save to /workspace/stable-diffusion-webui/relauncher.py
curl -L https://raw.githubusercontent.com/D8-Dreambooth/docker_dreambooth/main/relauncher.sh -o /workspace/stable-diffusion-webui/relauncher.py

# set the permissions so it's executable
chmod +x /workspace/launch.sh
chmod +x /workspace/stable-diffusion-webui/relauncher.py

/workspace/launch.sh