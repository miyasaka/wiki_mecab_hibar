#!/bin/bash
while :
do
	ps axl | grep prefork
	echo "--------------"
	sleep 2
done
