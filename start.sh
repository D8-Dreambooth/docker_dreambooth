#!/bin/bash
echo "Dreambooth Container Started"
export PYTHONUNBUFFERED=1
source /workspace/venv/bin/activate
cd /workspace/stable-diffusion-webui

if [[ "$UPDATE_EXTENSION" == "true" ]]; then
  cd /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension/
  git fetch && git pull
  cd /workspace/stable-diffusion-webui
fi

cd /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension/

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$current_branch" != "$BRANCH" ]]; then
  git checkout "$BRANCH"
  git fetch && git pull
  $UPDATE_WEBUI = "false"
fi

cd /workspace/stable-diffusion-webui

if [[ "$UPDATE_WEBUI" == "true" ]]; then
  cd /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension/
  git fetch && git pull
fi

cd /workspace/stable-diffusion-webui

python relauncher.py &

if [[ -n $PUBLIC_KEY ]]; then
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  cd ~/.ssh
  echo $PUBLIC_KEY >>authorized_keys
  chmod 700 -R ~/.ssh
  cd /
  service ssh start
  echo "SSH Service Started"
fi

sleep infinity
