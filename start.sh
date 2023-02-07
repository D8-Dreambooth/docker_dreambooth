#!/bin/bash
echo "Container Started"
export PYTHONUNBUFFERED=1
source /workspace/venv/bin/activate
cd /workspace/stable-diffusion-webui

pip install -r /workspace/stable-diffusion-webui/requirements_versions.txt
pip install -r /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension/requirements.txt

if [[ $TORCH2 ]]
then
	# Install Requirements
	pip install https://download.pytorch.org/whl/nightly/cu118/torch-2.0.0.dev20230202%2Bcu118-cp310-cp310-linux_x86_64.whl https://download.pytorch.org/whl/nightly/cu118/torchvision-0.15.0.dev20230202%2Bcu118-cp310-cp310-linux_x86_64.whl https://download.pytorch.org/whl/nightly/pytorch_triton-2.0.0%2B0d7e753227-cp310-cp310-linux_x86_64.whl

else
	pip install torch==1.13.1+cu118 torchvision==0.14.1+cu118 --extra-index-url https://download.pytorch.org/whl/cu118
	pip install xformers==0.0.17.dev442
fi

python relauncher.py &

if [[ $PUBLIC_KEY ]]
then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo $PUBLIC_KEY >> authorized_keys
    chmod 700 -R ~/.ssh
    cd /
    service ssh start
    echo "SSH Service Started"
fi

if [[ $JUPYTER_PASSWORD ]]
then
    ln -sf /examples /workspace
    ln -sf /root/welcome.ipynb /workspace

    cd /
    jupyter lab --allow-root --no-browser --port=8888 --ip=* \
        --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' \
        --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace
    echo "Jupyter Lab Started"
fi

sleep infinity
