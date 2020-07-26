#!/bin/bash

TOOL=nodemcu-tool

sudo ${TOOL} upload setup.lua -n init.lua
sudo ${TOOL} upload sensor.lua -n main.lua
sudo ${TOOL} upload settings.lua -n settings.lua
