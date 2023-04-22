#!/bin/bash
echo "SDPlus Container Started"
export PYTHONUNBUFFERED=1
source /app/stable-diffusion-plus/venv/bin/activate

cd /app/stable-diffusion-plus

if [[ "$UPDATE_WEBUI" == "true" ]]; then
  echo "Updating SD+"
  git fetch && git pull
fi

pip install
echo "Installing SDPlus requirements"
pip install -r /app/stable-diffusion-plus/requirements.txt

echo "Launching SDPlus..."
python launch.py &

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
