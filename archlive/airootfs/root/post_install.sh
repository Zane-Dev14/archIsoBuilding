#!/usr/bin/env bash
set -e

echo "[*] Running post_install.sh ..."

# Upgrade pip just in case
python -m pip install --upgrade pip --break-system-packages

# HuggingFace ecosystem
pip install --break-system-packages transformers accelerate datasets safetensors sentencepiece

# Extra ML/AI & utilities
pip install --break-system-packages evaluate scikit-learn-intelex
pip install --break-system-packages jupyterlab_widgets ipywidgets plotly tensorboard

echo "[*] Post-install complete. HuggingFace + AI stack ready!"
