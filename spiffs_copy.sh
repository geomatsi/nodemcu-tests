#!/bin/bash

TOOL=/home/matsi/bin/luatool.py
PORT=/dev/ttyUSB0
BAUD=115200

for f in "$@"
do
	sudo ${TOOL} --port ${PORT} --baud ${BAUD} --src ${f} --dest ${f}
	#sudo ${TOOL} --port ${PORT} --bar --compile --baud ${BAUD} --src ${f} --dest ${f}
done
