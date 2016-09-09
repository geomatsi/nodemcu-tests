#
#
#

SPIFFS_OFFSET ?= 0x70000
SPIFFS_SIZE ?= 524288
FLASH_SIZE ?= 32m
#FLASH_SIZE ?= 8m

all: info

info:
	echo "hello"

lib:
	sudo /home/matsi/bin/luatool.py --port /dev/ttyUSB0 --src nrf24.lua --dest nrf24.lua -b 115200

test1:
	sudo /home/matsi/bin/luatool.py --port /dev/ttyUSB0 --src test1.lua --dest test1.lua -b 115200

test2:
	sudo /home/matsi/bin/luatool.py --port /dev/ttyUSB0 --src test2.lua --dest test2.lua -b 115200

test3:
	sudo /home/matsi/bin/luatool.py --port /dev/ttyUSB0 --src test3.lua --dest test3.lua -b 115200

image:
	spiffsimg -f fs.img -S ${FLASH_SIZE} -U ${SPIFFS_SIZE} -r script.img

flash:
	sudo /home/matsi/bin/esptool.py --port /dev/ttyUSB0 write_flash -fm dio -fs ${FLASH_SIZE} ${SPIFFS_OFFSET} fs.img

clean:
	rm -rf fs.img
