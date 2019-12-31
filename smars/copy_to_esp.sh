#!/bin/bash

TOOL=${HOME}/bin/luatool.py
PORT=/dev/ttyUSB0
RATE=115200

sudo ${TOOL} --port ${PORT} --src init.lua --dest init.lua -b ${RATE}
sudo ${TOOL} --port ${PORT} --src smars-usound-simple.lua --dest smars.lua -b ${RATE}
