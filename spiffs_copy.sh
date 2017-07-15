#!/bin/bash

TOOL=/home/matsi/bin/luatool.py
PORT=/dev/ttyUSB0
BAUD=115200

LIST="init.lua nrf24.lua test1.lua test2.lua test3.lua test4.lua"

for f in ${LIST} ; do
	sudo ${TOOL} --port ${PORT} --bar --compile --baud ${BAUD} --src ${f} --dest ${f}
done
