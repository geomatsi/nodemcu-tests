#!/bin/bash

TOOL=nodemcu-tool

sudo ${TOOL} upload ../init.lua -n init.lua
sudo ${TOOL} upload cred.lua -n cred.lua
sudo ${TOOL} upload test1.lua -n main.lua
