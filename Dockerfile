ARG BASE_IMAGE=digitalhigh/dreambooth_base:latest
FROM ${BASE_IMAGE} as cuda-base

WORKDIR /

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND noninteractive\
    SHELL=/bin/bash

WORKDIR /workspace


RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

WORKDIR /workspace/

# Create venv
ENV VIRTUAL_ENV=/workspace/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install dependencies:
RUN pip install git+https://github.com/TencentARC/GFPGAN.git
RUN pip install git+https://github.com/openai/CLIP.git
RUN pip install git+https://github.com/mlfoundations/open_clip.git

RUN pip install https://github.com/ArrowM/xformers/releases/download/xformers-0.0.17-cu118-linux/xformers-0.0.17+7f4fdce.d20230204-cp310-cp310-linux_x86_64.whl
RUN pip install https://download.pytorch.org/whl/nightly/cu118/torch-2.0.0.dev20230202%2Bcu118-cp310-cp310-linux_x86_64.whl https://download.pytorch.org/whl/nightly/cu118/torchvision-0.15.0.dev20230202%2Bcu118-cp310-cp310-linux_x86_64.whl https://download.pytorch.org/whl/nightly/pytorch_triton-2.0.0%2B0d7e753227-cp310-cp310-linux_x86_64.whl

RUN jupyter nbextension enable --py widgetsnbextension


RUN if [ ! -d "/workspace/venv" ]; then \
    echo "Directory '/workspace/venv' does not exist" \
    ; else \
    echo "Directory '/workspace/venv' exists" \
    ; fi
	


WORKDIR /workspace/stable-diffusion-webui
WORKDIR /workspace/stable-diffusion-webui/extensions
RUN git clone -b Torch2 https://github.com/d8ahazard/sd_dreambooth_extension.git
RUN git clone https://github.com/yfszzx/stable-diffusion-webui-images-browser.git

WORKDIR /workspace/stable-diffusion-webui/

RUN git clone https://github.com/CompVis/stable-diffusion.git ./repositories/stable-diffusion
RUN git clone https://github.com/CompVis/taming-transformers.git ./repositories/taming-transformers
RUN git clone https://github.com/sczhou/CodeFormer.git ./repositories/CodeFormer
RUN git clone https://github.com/salesforce/BLIP.git ./repositories/BLIP
RUN git clone https://github.com/crowsonkb/k-diffusion.git ./repositories/k-diffusion
RUN git clone https://github.com/Stability-AI/stablediffusion.git ./repositories/stable-diffusion-stability-ai

COPY --from=digitalhigh/dreambooth_venv:latest /workspace/models/ /workspace/models/

SHELL ["/bin/bash", "-c"]

RUN mkdir -p /root/.cache/huggingface
RUN mkdir -p /workspace/outputs

ADD ui-config.json /workspace/stable-diffusion-webui/ui-config.json
ADD relauncher.py .
ADD start.sh /start.sh
RUN chmod a+x /start.sh
SHELL ["/bin/bash", "--login", "-c"]
