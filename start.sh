#!/bin/bash
echo "Dreambooth Container Started"
export PYTHONUNBUFFERED=1
source /workspace/venv/bin/activate
cd /workspace/stable-diffusion-webui

if [[ ! -f /workspace/.first_run ]]; then
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

if [[ "$TORCH2" == "true" ]]; then
  # Get the current date in the format YYYYMMDD
  current_date=$(date +%Y%m%d)

  # Check if $TORCH_REVISION is set
  if [ -z "$TORCH_REVISION" ]; then
    torch_revision=$current_date
  else
    torch_revision=$TORCH_REVISION
  fi

  # Use the value of $torch_revision in the URL
  torch_url="https://download.pytorch.org/whl/nightly/cu118/torch-2.0.0.dev${torch_revision}%2Bcu118-cp310-cp310-linux_x86_64.whl"
  torch_vision_url="https://download.pytorch.org/whl/nightly/cu118/torchvision-0.15.0.dev{torch_revision}%2Bcu118-cp310-cp310-linux_x86_64.whl"
  torch_triton_url="https://download.pytorch.org/whl/nightly/cu118/pytorch_triton-2.0.0%2B0d7e753227-cp310-cp310-linux_x86_64.whl"
  # Install Requirements
  # Create wheel cache directory if it doesn't exist
  mkdir -p /workspace/wheel_cache

  # Check if the wheel files exist in the cache
  if [ ! -f /workspace/wheel_cache/torch-2.0.0.dev${torch_revision}%2Bcu118-cp310-cp310-linux_x86_64.whl ] ||
    [ ! -f /workspace/wheel_cache/torchvision-0.15.0.dev{torch_revision}%2Bcu118-cp310-cp310-linux_x86_64.whl ] ||
    [ ! -f /workspace/wheel_cache/pytorch_triton-2.0.0%2B0d7e753227-cp310-cp310-linux_x86_64.whl ]; then

    # Download wheel files if they don't exist
    wget "$torch_url" -P /workspace/wheel_cache
    wget "$torch_vision_url" -P /workspace/wheel_cache
    wget "$torch_triton_url" -P /workspace/wheel_cache
  fi

  # Install Requirements
  pip install /workspace/wheel_cache/torch-2.0.0.dev${torch_revision}%2Bcu118-cp310-cp310-linux_x86_64.whl \
    /workspace/wheel_cache/torchvision-0.15.0.dev{torch_revision}%2Bcu118-cp310-cp310-linux_x86_64.whl \
    /workspace/wheel_cache/pytorch_triton-2.0.0%2B0d7e753227-cp310-cp310-linux_x86_64.whl
  pip install ninja sympy
  # Set TORCH_CUDA_ARCH_LIST if running and building on different GPU types
  export TORCH_CUDA_ARCH_LIST="6.0;6.1;6.2;7.0;7.2;7.5;8.0;8.6"
  pip install -v -U git+https://github.com/facebookresearch/xformers.git@main#egg=xformers
else
  pip install torch==1.13.1+cu118 torchvision==0.14.1+cu118 --extra-index-url https://download.pytorch.org/whl/cu118
  pip install xformers==0.0.17.dev442
fi

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
