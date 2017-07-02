# Notes

## How to copy Lua scripts to device spiffs
```bash
$ sudo /home/matsi/bin/luatool.py --port /dev/ttyUSB0 --src test.lua --dest test.lua -b 115200
```

## How to create and flash spiffs image
Create image content list
```bash
$ cat script.img
import init.lua init.lua
import test.lua test.lua
import nrf24.lua nrf24.lua
```

Generate spiffs image
```bash
$ spiffsimg -f fs.img -S ${FLASH_SIZE} -U ${SPIFFS_SIZE} -r script.img
```

Flash spiffs image to device
```bash
$ sudo /home/matsi/bin/esptool.py --port /dev/ttyUSB0 write_flash -fm dio -fs ${FLASH_SIZE} ${SPIFFS_OFFSET} fs.img
```
