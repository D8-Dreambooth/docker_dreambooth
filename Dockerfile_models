ARG BASE_IMAGE=ubuntu:18.04
FROM ${BASE_IMAGE} as buntu-base

RUN apt-get update --yes && \
    apt install --yes --no-install-recommends\
    wget &&\
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

WORKDIR /workspace

WORKDIR /workspace/
RUN mkdir /workspace/models
RUN wget https://huggingface.co/stabilityai/stable-diffusion-2-1/resolve/main/v2-1_768-nonema-pruned.safetensors -O /workspace/models/v2-1_768-nonema-pruned.safetensors --no-check-certificate
RUN wget https://huggingface.co/ckpt/stable-diffusion-2-1/raw/main/v2-inference-v.yaml -O /workspace/models/v2-1_768-nonemaema-pruned.yaml --no-check-certificate
