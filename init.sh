#!/bin/bash

for each in `ls scripts/*.sh | sort -V`
do 
	echo "Running: $each"
	bash $each | tee -a $HOME/init.log
done
