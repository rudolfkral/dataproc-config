#!/bin/bash

for each in `ls scripts/*.sh | sort -V`
do 
	# make sure we
	cd
	echo "Running: $each"
	bash $each | tee -a $HOME/init.log
done
