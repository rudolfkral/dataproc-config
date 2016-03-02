#!bin/sh

for each in scripts/*.sh
do 
	bash $each >> $HOME/init.log
done