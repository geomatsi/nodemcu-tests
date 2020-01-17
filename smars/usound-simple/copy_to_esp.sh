#!/bin/bash

TOOL=nodemcu-tool

sudo ${TOOL} upload ../init.lua -n init.lua
sudo ${TOOL} upload smars-usound-simple.lua -n smars.lua
