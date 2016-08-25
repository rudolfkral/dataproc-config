#!/bin/bash

for each in `ls scripts/*.sh | sort -V`
do
	# make sure we are in the home
	cd
	echo "Running: $each" | tee -a $HOME/init.log 
	bash $each | tee -a $HOME/init.log
done
