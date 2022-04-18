#!/bin/bash

sleep 240
cd /home/kali/

for((i=0; i<20; i++))
do
	./attack.py www.heartbleedlabelgg.com
	sleep 10
	./attack.py www.heartbleedlabelgg.com
	sleep 32
done