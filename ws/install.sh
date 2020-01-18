#!/bin/bash

TOOL=nodemcu-tool

sudo ${TOOL} upload ../init.lua -n init.lua
sudo ${TOOL} upload settings.lua -n settings.lua
sudo ${TOOL} upload test.lua -n main.lua
