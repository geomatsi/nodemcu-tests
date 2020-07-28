-- gpio <-> index mapping: https://nodemcu.readthedocs.io/en/master/modules/gpio/

-- WDG/LED: D4/GPIO2
WDG_PIN = 4

-- PINS: D0/GPIO16, D5/GPIO14, D6/GPIO12, D7/GPIO13
RSW_PIN1 = 0
RSW_PIN2 = 5
RSW_PIN3 = 6
RSW_PIN4 = 7

-- I2C: SDA (D1/GPIO5), SCL (D2/GPIO4)
I2C_SDA = 1
I2C_SCL = 2

-- WiFi AP
WIFI_SSID = "ssid"
WIFI_PASS = "pass"

-- MQTT server
MQTT_ADDR = "192.168.88.254"
MQTT_PORT = 1883
MQTT_RSSI = "/node/rssi"
MQTT_FREE = "/node/free"
MQTT_PINS = "/node/pins"
MQTT_TEMP = "/node/temp"
MQTT_LIGHT = "/node/light"
