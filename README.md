# Notes

## How to copy Lua scripts to device spiffs

Using [luatool](https://github.com/4refr0nt/luatool):
```bash
$ sudo luatool.py --port /dev/ttyUSB0 --src test.lua --dest test.lua -b 115200
```

Using [nodemcu-tool](https://github.com/AndiDittrich/NodeMCU-Tool):
```bash
$ sudo nodemcu-tool upload init.lua
$ sudo nodemcu-tool upload test.lua -n main.lua
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
