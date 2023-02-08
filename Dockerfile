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
RUN pip install git+https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379
RUN pip install git+https://github.com/openai/CLIP.git@d50d76daa670286dd6cacf3bcd80b5e4823fc8e1
RUN pip install git+https://github.com/mlfoundations/open_clip.git@bb6e834e9c70d9c27d0dc3ecedeebeaeb1ffad6b


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

RUN git clone https://github.com/Stability-AI/stable-diffusion.git ./repositories/stable-diffusion
RUN git -C /workspace/stable-diffusion-webui/repositories/stable-diffusion checkout "47b6b607fdd31875c9279cd2f4f16b92e4ea958e"

RUN git clone https://github.com/CompVis/taming-transformers.git ./repositories/taming-transformers
RUN git -C /workspace/stable-diffusion-webui/repositories/taming-transformers checkout "24268930bf1dce879235a7fddd0b2355b84d7ea6"

RUN git clone https://github.com/sczhou/CodeFormer.git ./repositories/CodeFormer
RUN git -C /workspace/stable-diffusion-webui/repositories/CodeFormer checkout "c5b4593074ba6214284d6acd5f1719b6c5d739af"

RUN git clone https://github.com/salesforce/BLIP.git ./repositories/BLIP
RUN git -C /workspace/stable-diffusion-webui/repositories/BLIP checkout "48211a1594f1321b00f14c9f7a5b4813144b2fb9"

RUN git clone https://github.com/crowsonkb/k-diffusion.git ./repositories/k-diffusion
RUN git -C /workspace/stable-diffusion-webui/repositories/k-diffusion checkout "5b3af030dd83e0297272d861c19477735d0317ec"

WORKDIR /workspace/stable-diffusion-webui/


COPY --from=digitalhigh/dreambooth_venv:latest /workspace/models/ /workspace/models/

SHELL ["/bin/bash", "-c"]

RUN mkdir -p /root/.cache/huggingface
RUN mkdir -p /workspace/outputs

ADD ui-config.json /workspace/stable-diffusion-webui/ui-config.json
ADD relauncher.py .
ADD start.sh /start.sh
RUN chmod a+x /start.sh

EXPOSE 22/tcp
EXPOSE 22/udp
EXPOSE 3000/tcp

# Set to have the container update the dreambooth extension on container start.
ENV UPDATE_EXTENSION="false"

# Update the Auto1111 WebUI on container start.
ENV UPDATE_WEBUI="false"

# Set to install torch2. Otherwise, torch 1.1.13 will be used.
ENV TORCH2="false"

# Set for openSSH access. Runpod automatically sets this if configured in user settings.
ENV PUBLIC_KEY=""

ENV JUPYTER_PASSWORD=""

ENV API_KEY=""

ENV TORCH_REVISION=""

ENV BRANCH="main"

SHELL ["/bin/bash", "--login", "-c"]
