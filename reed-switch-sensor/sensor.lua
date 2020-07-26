-- load software/hardware configuration

dofile("settings.lua")

-- adc: read light sensor data

local function get_light()
	print("light:", adc.read(0))
end

-- gpio: reed switch reading

local function get_rs()
	local v1 = gpio.read(RSW_PIN1)
	local v2 = gpio.read(RSW_PIN2)
	local v3 = gpio.read(RSW_PIN3)
	local v4 = gpio.read(RSW_PIN4)
	print("reed switches: " .. v1 .. "/" .. v2 .. "/" .. v3 .. "/" .. v4)
end

-- i2c: read temperature sensor

local function get_temp()
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

	print("I2C read: " .. temp)
end

--
-- main
--

-- init hardware

if adc.force_init_mode(adc.INIT_VDD33) then
	print("adc reconfigured: reboot scheduled...")
	node.restart()
end

gpio.mode(RSW_PIN1, gpio.INPUT)
gpio.mode(RSW_PIN2, gpio.INPUT)
gpio.mode(RSW_PIN3, gpio.INPUT)
gpio.mode(RSW_PIN4, gpio.INPUT)

i2c.setup(0, I2C_SDA, I2C_SCL, i2c.SLOW)

-- start readers

tmr.create():alarm(10 * 1000, tmr.ALARM_AUTO, get_light)
tmr.create():alarm(30 * 1000, tmr.ALARM_AUTO, get_temp)
tmr.create():alarm(5 * 1000, tmr.ALARM_AUTO, get_rs)