#!/bin/bash

sleep 260 
cd /home/kali/

for((i=0; i<40; i++))
do
	./attack.py www.heartbleedlabelgg.com
	sleep 20
	./attack.py www.heartbleedlabelgg.com
	sleep 38
done