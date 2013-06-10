#!/bin/bash
DIR="/home/public/frontier/"

for i in `seq 0 9999`
do
	echo $DIR$i
	 mkdir -p $DIR$i
done
