-- load software/hardware configuration

dofile("settings.lua")

-- ADC: read light sensor data

local function get_light()
	local data = adc.read(0)
	print("light:", data)
	return data
end

-- GPIO: reed switch reading

local function get_reed_switches()
	local v1 = gpio.read(RSW_PIN1)
	local v2 = gpio.read(RSW_PIN2)
	local v3 = gpio.read(RSW_PIN3)
	local v4 = gpio.read(RSW_PIN4)
	print("reed switches: " .. v1 .. "/" .. v2 .. "/" .. v3 .. "/" .. v4)
	return string.format("%d/%d/%d/%d", v1, v2, v3, v4)
end

local function gpio_event(client)
	return function()
		local pins = get_reed_switches()
		client:publish(MQTT_PINS, pins, 0 , 0)
	end
end

local function gpio_init(pin, client)
	if (pin ~= 0) then
		gpio.mode(pin, gpio.INT)
		gpio.trig(pin, "both", gpio_event(client))
	else
		gpio.mode(pin, gpio.INPUT)
	end
end

-- I2C: read temperature sensor

local function get_temperature()
	-- Example for LM75A temperature i2c sensor
	--   device address: 0x48
	--   temperature register (read 2 bytes): 0x0
	i2c.start(0)
	i2c.address(0, 0x48, i2c.TRANSMITTER)
	i2c.write(0, 0x0)
	i2c.stop(0)
	i2c.start(0)
	i2c.address(0, 0x48, i2c.RECEIVER)
	local data = i2c.read(0, 2)
	i2c.stop(0)

	-- temperature calculation according to LM75A spec
	local msb = data:byte(1)
	local lsb = data:byte(2)
	local temp = 255

	if (bit.isset(msb, 7)) then
		temp = -1.0 * bit.clear(msb, 7)
	else
		temp = 1.0 * msb
	end

	if (bit.isset(lsb, 7)) then
		temp = temp + 0.5
	end

	print("temperature:", temp)
	return temp
end

-- MQTT

local function create_mqtt_action_callback(client)
	return function()
		local ret = true

		print("MQTT publish...")

		local free = string.format("%d", bit.rshift(node.heap(), 10))
		ret = client:publish(MQTT_FREE, free, 0, 0)

		if (not ret) then
			return
		end

		local rssi = wifi.sta.getrssi()
		if (rssi ~= nil) then
			rssi = string.format("%d", rssi)
		else
			rssi = "none"
		end
		ret = client:publish(MQTT_RSSI, rssi, 0, 0)

		if (not ret) then
			return
		end

		local light = get_light()
		ret = client:publish(MQTT_LIGHT, light, 0 , 0)

		if (not ret) then
			return
		end

		local temp = get_temperature()
		ret = client:publish(MQTT_TEMP, temp, 0 , 0)

		if (not ret) then
			return
		end

		local pins = get_reed_switches()
		ret = client:publish(MQTT_PINS, pins, 0 , 0)

		if (not ret) then
			return
		end

		tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, create_mqtt_action_callback(client))
	end
end

local function mqtt_connected(client)
	print("MQTT connected...")
	tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, create_mqtt_action_callback(client))
end

local function mqtt_reconnect(client)
	print("MQTT connect failed...")
	tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, create_mqtt_retry_callback(client))
end

function create_mqtt_retry_callback(client)
	return function()
		print("MQTT reconnect...")
		client:connect(MQTT_ADDR, MQTT_PORT, mqtt_connected, mqtt_reconnect)
	end
end

-- WIFI

local function wifi_connect_event(conn)
	print("Connected to AP(" .. conn.SSID .. ")...")
end

local function wifi_ip_addr_event(conn)
	print("Obtained IP(" .. conn.IP .. ")...")
	m:connect(MQTT_ADDR, MQTT_PORT, mqtt_connected, mqtt_reconnect)
end

local function wifi_disconnect_event(conn)
	if conn.reason == wifi.eventmon.reason.ASSOC_LEAVE then
		print("disconnected...")
		return
	else
		print("Failed to connect to AP(" .. conn.SSID .. ")")
	end

	for key,val in pairs(wifi.eventmon.reason) do
		if val == conn.reason then
			print("Reason: " .. val .. "(" .. key .. ")")
			break
		end
	end
end

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, wifi_connect_event)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wifi_ip_addr_event)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, wifi_disconnect_event)

--
-- main
--

-- init mqtt client
m = mqtt.Client("test", 120)
m:on("offline", mqtt_reconnect)

-- init ADC hardware
if adc.force_init_mode(adc.INIT_VDD33) then
	print("adc reconfigured: reboot scheduled...")
	node.restart()
end

-- init pins connected to Reed switches: use interrupts if possible
gpio_init(RSW_PIN1, m)
gpio_init(RSW_PIN2, m)
gpio_init(RSW_PIN3, m)
gpio_init(RSW_PIN4, m)

-- init I2C connected to temperature sensor
i2c.setup(0, I2C_SDA, I2C_SCL, i2c.SLOW)

-- init wifi connection
print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=WIFI_SSID, pwd=WIFI_PASS})
