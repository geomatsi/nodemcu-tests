#!/bin/bash

SPIFFS_OFFSET ?= 0x70000
SPIFFS_SIZE ?= 524288
FLASH_SIZE ?= 32m

ESPTOOL=/home/matsi/bin/esptool.py
PORT=/dev/ttyUSB0

# create SPIFFS image
spiffsimg -f fs.img -S ${FLASH_SIZE} -U ${SPIFFS_SIZE} -r script.img

# write SPIFFS image to flash
sudo ${ESPTOOL} --port ${PORT} write_flash -fm dio -fs ${FLASH_SIZE} ${SPIFFS_OFFSET} fs.img
