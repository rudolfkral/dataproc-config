#!/bin/bash
set -e

# 0. Specify Packages to be installed
## 0.1 conda packages to be installed
CONDA_PACKAGES='scipy numpy pandas scikit-learn networkx numexpr seaborn bokeh ipython Jupyter pytables lxml tornado sqlalchemy mysql-connector-python=2.0.4 nltk'
## 0.2 pip packages to be installed

CONDA_ENV_NAME='root'

echo "echo \$USER: $USER"
echo "echo \$PWD: $PWD"
echo "echo \$PATH: $PATH"
echo "echo \$CONDA_BIN_PATH: $CONDA_BIN_PATH"

source /etc/profile.d/conda_config.sh

echo "echo \$USER: $USER"
echo "echo \$PWD: $PWD"
echo "echo \$PATH: $PATH"
echo "echo \$CONDA_BIN_PATH: $CONDA_BIN_PATH"

# 1. Create conda env and install conda packages
echo "Attempting to create conda environment: $CONDA_ENV_NAME"
echo "Creating conda environment and installing conda packages..."
echo "Installing CONDA_PACKAGES for $CONDA_ENV_NAME..."
echo "conda packages requested: $CONDA_PACKAGES"
conda install $CONDA_PACKAGES
pip install -r /dataproc-config/requirements.txt

python -c "import nltk; nltk.download('punkt')"

# 2. Append .bashrc with source activate
echo "Attempting to append .bashrc to activate conda env at login..."
echo "Appending .bashrc to activate conda env at login.."
sudo echo "source activate $CONDA_ENV_NAME"         >> $HOME/.bashrc
echo ".bashrc successfully appended!"
