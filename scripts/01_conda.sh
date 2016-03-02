#!/bin/bash
set -e

# Run on BOTH 'Master' and 'Worker' nodes
#ROLE=$(/usr/share/google/get_metadata_value attributes/dataproc-role)
#if [[ "${ROLE}" == 'Master' ]]; then

# Update gcloud SDK command line
gcloud components update -q

CONDA_INSTALL_PATH="/usr/local/bin/miniconda"
PROJ_DIR="/cluster"

# 0. Specify Miniconda version
# 0.1 A few parameters
# specify base operating system
OS_TYPE="Linux-x86_64.sh"
# specify Miniconda release
MINICONDA_VER='3.19.0'

#for Python 3.5.x
MINICONDA_VARIANT="Miniconda3"  
expectedHash="b834b525d3f42add8f2af0153d13f498"

## 0. Compute Miniconda version
miniconda="$MINICONDA_VARIANT-$MINICONDA_VER-$OS_TYPE"

# 1. Setup Miniconda Install
## 1.1 Define Miniconda install directory
mkdir -p PROJ_DIR

## 1.2 Setup Miniconda
cd $PROJ_DIR
MINICONDA_SCRIPT_PATH="$PROJ_DIR/$miniconda"
echo "Defined miniconda script path: $MINICONDA_SCRIPT_PATH"
echo "Downloading Miniconda script to: $MINICONDA_SCRIPT_PATH ..."
wget http://repo.continuum.io/miniconda/$miniconda -P "$PROJ_DIR"
echo "Downloaded $miniconda!"
ls -al $MINICONDA_SCRIPT_PATH
chmod 755 $MINICONDA_SCRIPT_PATH

# 1.3 #md5sum hash check of miniconda installer
md5Output=$(md5sum $MINICONDA_SCRIPT_PATH | awk '{print $1}')
if [ "$expectedHash" != "$md5Output" ]; then
    echo "Unexpected md5sum $md5Output for $miniconda"
    exit 1
fi

# 2. Install Conda
## 2.1 Via bootstrap
LOCAL_CONDA_PATH="$PROJ_DIR/miniconda"
#blow away old symlink / default Miniconda install
rm -rf "$PROJ_DIR/miniconda"
# Install Miniconda
echo "Installing $miniconda to $CONDA_INSTALL_PATH..."
bash $MINICONDA_SCRIPT_PATH -b -p $CONDA_INSTALL_PATH -f
chmod 755 $CONDA_INSTALL_PATH
#create symlink
ln -sf $CONDA_INSTALL_PATH "$PROJ_DIR/miniconda"
chmod 755 "$PROJ_DIR/miniconda"

# 2.2 Update PATH and conda...
echo "Setting environment variables..."
CONDA_BIN_PATH="$CONDA_INSTALL_PATH/bin"
export PATH="$CONDA_BIN_PATH:$PATH"
echo "Updated PATH: $PATH"
echo "And also HOME: $HOME"
hash -r
which conda
conda config --set always_yes yes --set changeps1 no
source $HOME/.bashrc

echo "Updating conda..."
conda update -q conda
# Useful for debugging any issues with conda
conda info -a

# Install useful conda utilities in root env
echo "Installing useful conda utilities in root env..."
conda install pip anaconda-client conda-build conda-env
conda install -n root -c conda conda-env
pip install py4j

# 2.3 Update global profiles to add the miniconda location to PATH and PYTHONHASHSEED
# based on: http://stackoverflow.com/questions/14637979/how-to-permanently-set-path-on-linux
# and also: http://askubuntu.com/questions/391515/changing-etc-environment-did-not-affect-my-environemtn-variables
# and this: http://askubuntu.com/questions/128413/setting-the-path-so-it-applies-to-all-users-including-root-sudo
echo "Updating global profiles to export miniconda bin location to PATH and set PYTHONHASHSEED ..."
echo "Adding path definition to profiles..."
echo "export CONDA_BIN_PATH=$CONDA_BIN_PATH" | tee -a /etc/profile.d/conda_config.sh  $HOME/.bashrc /etc/profile #/etc/environment
echo 'export PATH=$CONDA_BIN_PATH:$PATH' | tee -a /etc/profile.d/conda_config.sh  $HOME/.bashrc /etc/profile #/etc/environment
# Fix issue with Python3 hash seed.
# Issue here: https://issues.apache.org/jira/browse/SPARK-12100
# Fix here: http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed/
echo "Adding PYTHONHASHSEED=0 to profiles and spark-defaults.conf..."
echo "export PYTHONHASHSEED=0" | tee -a  /etc/profile.d/conda_config.sh  $HOME/.bashrc /usr/lib/spark/conf/spark-env.sh #/etc/environment
echo "spark.executorEnv.PYTHONHASHSEED=0" >> /etc/spark/conf/spark-defaults.conf

## 3. Ensure that Anaconda Python and PySpark play nice
### http://blog.cloudera.com/blog/2015/09/how-to-prepare-your-apache-hadoop-cluster-for-pyspark-jobs/
echo "Ensure that Anaconda Python and PySpark play nice by all pointing to same Python distro..."
echo "export PYSPARK_PYTHON=$CONDA_BIN_PATH/python" | tee -a  /etc/profile.d/conda_config.sh \ 
    $HOME/.bashrc /etc/environment /usr/lib/spark/conf/spark-env.sh; 

echo "Finished bootstrapping via Miniconda, sourcing .bashrc..."
source $HOME/.bashrc