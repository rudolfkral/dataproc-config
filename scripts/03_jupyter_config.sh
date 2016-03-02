
#!/bin/bash

# Only run on the master node
ROLE=$(/usr/share/google/get_metadata_value attributes/dataproc-role)
if [[ "${ROLE}" == 'Master' ]]; then
	# Install iPython Notebook and create a profile
	cd
	mkdir IPythonNB
	cd IPythonNB
	ipython profile create default
	
	# Set up configuration for iPython Notebook
	echo "c = get_config()" >  /root/.ipython/profile_default/ipython_notebook_config.py
	echo "c.NotebookApp.ip = '*'" >>  /root/.ipython/profile_default/ipython_notebook_config.py
	echo "c.NotebookApp.open_browser = False"  >>  /root/.ipython/profile_default/ipython_notebook_config.py
	echo "c.NotebookApp.port = 8123" >>  /root/.ipython/profile_default/ipython_notebook_config.py
	
	# Setup script for iPython Notebook so it uses the cluster's Spark
	cat > /root/.ipython/profile_default/startup/00-pyspark-setup.py <<'_EOF'
import os
import sys
spark_home = '/usr/lib/spark/'
os.environ["SPARK_HOME"] = spark_home
sys.path.insert(0, os.path.join(spark_home, 'python'))
sys.path.insert(0, os.path.join(spark_home, 'python/lib/py4j-0.9-src.zip'))
exec(compile(open(os.path.join(spark_home, 'python/pyspark/shell.py')).read(), os.path.join(spark_home, 'python/pyspark/shell.py'), 'exec'))
_EOF
	
	# Start iPython Notebook on port 8123
	# add it to starting scripts
	touch /etc/profile.d/start_jupyter.sh
	chmod +x /etc/profile.d/start_jupyter.sh
	echo "nohup jupyter notebook --no-browser --ip=* --port=8123 > tee /var/log/python_notebook.log &" | tee -a /etc/profile.d/start_jupyter.sh
	/etc/profile.d/start_jupyter.sh
fi
