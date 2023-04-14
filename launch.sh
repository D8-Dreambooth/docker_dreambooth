#!/bin/bash
echo "Dreambooth Container Started"
export PYTHONUNBUFFERED=1
source /workspace/venv/bin/activate

cd /workspace/stable-diffusion-webui

if [[ "$UPDATE_WEBUI" == "true" ]]; then
  echo "Updating SD WebUI"
  cd /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension/
  git fetch && git pull
fi

cd /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension/

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$current_branch" != "$BRANCH" ]]; then
  echo "Switching extension branch to $BRANCH"
  git checkout "$BRANCH"
  UPDATE_EXTENSION="true"
fi


cd /workspace/stable-diffusion-webui

if [[ "$UPDATE_EXTENSION" == "true" ]]; then
  echo "Updating dreambooth extension"
  cd /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension/
  git fetch && git pull
  cd /workspace/stable-diffusion-webui
fi


echo "Updating WebUI requirements"
cat ./requirements_versions.txt ./extensions/sd_dreambooth_extension/requirements_extra.txt > /tmp/combined_ext_requirements.txt
pip install -r /tmp/combined_requirements.txt

# Need this version to prevent errors on startup
pip install --upgrade fastapi==0.90.1
pip install xformers==0.0.18
pip install mediapipe

echo "Launching relauncher..."
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
