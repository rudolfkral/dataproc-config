#!/bin/bash

for each in `ls scripts/*.sh | sort -V`
do
	# make sure we are in the home
	cd
	echo "Running: $each" | tee -a $HOME/init.log 
	bash $each | tee -a $HOME/init.log
done

# running conditional code
/usr/local/bin/miniconda/bin/python scripts/050_conditionals.py | tee -a $HOME/init.log