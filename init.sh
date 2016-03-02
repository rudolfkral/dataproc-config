#!/bin/bash

for each in scripts/*.sh
do 
	bash $each | tee -a $HOME/init.log
done
