#!/bin/bash
set -e -u

echo "[NeuronOS] Installing ML/AI frameworks and NVIDIA stack from local repo..."

# Install everything from your local repo
pacman -Syu --noconfirm \
  python-pytorch-cuda \
  python-tensorflow-cuda \
  onnxruntime \
  python-onnx \
  nvidia-dkms \
  nvidia-utils \
  nvidia-settings \
  opencl-nvidia \
  cuda \
  cudnn \
  nvtop \
  nvidia-prime

# Disable this service so it runs only once
systemctl disable install-ml.service

echo "[NeuronOS] ML/AI stack installation complete!"
