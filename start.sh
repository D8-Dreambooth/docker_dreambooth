#!/bin/bash
echo "Dreambooth Container Started"
export PYTHONUNBUFFERED=1
source /workspace/venv/bin/activate
cd /workspace/stable-diffusion-webui

if [[ ! -f /workspace/.first_run ]]; then
  cd /workspace/stable-diffusion-webui/

  git clone https://github.com/CompVis/taming-transformers.git ./repositories/taming-transformers
  git -C /workspace/stable-diffusion-webui/repositories/taming-transformers checkout "24268930bf1dce879235a7fddd0b2355b84d7ea6"

  git clone https://github.com/Stability-AI/stablediffusion.git ./repositories/stable-diffusion-stability-ai
  git -C /workspace/stable-diffusion-webui/repositories/stable-diffusion-stability-ai checkout "47b6b607fdd31875c9279cd2f4f16b92e4ea958e"
  pip install -r /workspace/stable-diffusion-webui/repositories/stable-diffusion-stability-ai/requirements.txt

  git clone https://github.com/sczhou/CodeFormer.git ./repositories/CodeFormer
  git -C /workspace/stable-diffusion-webui/repositories/CodeFormer checkout "c5b4593074ba6214284d6acd5f1719b6c5d739af"
  pip install -r /workspace/stable-diffusion-webui/repositories/CodeFormer/requirements.txt

  git clone https://github.com/salesforce/BLIP.git ./repositories/BLIP
  git -C /workspace/stable-diffusion-webui/repositories/BLIP checkout "48211a1594f1321b00f14c9f7a5b4813144b2fb9"
  pip install -r /workspace/stable-diffusion-webui/repositories/BLIP/requirements.txt

  git clone https://github.com/crowsonkb/k-diffusion.git ./repositories/k-diffusion

  pip install -r /workspace/stable-diffusion-webui/requirements_versions.txt
  pip install -r /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension/requirements.txt
  touch /workspace/.first_run
fi

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

if [[ -n $JUPYTER_PASSWORD ]]; then
  ln -sf /examples /workspace
  ln -sf /root/welcome.ipynb /workspace

  cd /
  jupyter lab --allow-root --no-browser --port=8888 --ip=* \
    --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' \
    --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace
  echo "Jupyter Lab Started"
fi

sleep infinity
