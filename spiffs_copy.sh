#!/bin/bash

TOOL=/home/matsi/bin/luatool.py
PORT=/dev/ttyUSB0
BAUD=115200

LIST ?= init.lua

for f in ${LIST_INIT} ; do
	sudo ${TOOL} --port ${PORT} --bar --baud ${BAUD} --src ${f} --dest ${f}
	#sudo ${TOOL} --port ${PORT} --bar --compile --baud ${BAUD} --src ${f} --dest ${f}
done
