-- Settings

dofile("settings.lua")

local led_timer = tmr.create()
local adc_timer = tmr.create()
local pin_timer = tmr.create()

-- HELP

function test_help()
	print("LED: led_start/led_stop")
	print("ADC: adc_start/adc_stop")
	print("PIN: pin_start/pin_stop")
end

-- LED

local function led_toggle()
	local val = gpio.read(LED_PIN)
	if (val == 0) then
		gpio.write(LED_PIN, gpio.HIGH)
	else
		gpio.write(LED_PIN, gpio.LOW)
	end
end

function led_start()
	print("start led test")
	led_timer:start()
end

function led_stop()
	print("stop led test")
	led_timer:stop()
end

-- ADC

local function adc_reader()
	print("System voltage reading (mV):", adc.readvdd33(0))
	print("Channel 0 reading:", adc.read(0))
end

function adc_start()
	print("start adc test")
	adc_timer:start()
end

function adc_stop()
	print("stop adc test")
	adc_timer:stop()
end

-- GPIO PINS

local function pin_reader()
	local v1 = gpio.read(TST_PIN1)
	local v2 = gpio.read(TST_PIN2)
	local v3 = gpio.read(TST_PIN3)
	local v4 = gpio.read(TST_PIN4)
	print("gpio: " .. v1 .. "/" .. v2 .. "/" .. v3 .. "/" .. v4)
end

function pin_start()
	print("start gpio test")
	pin_timer:start()
end

function pin_stop()
	print("stop gpio test")
	pin_timer:stop()
end


-- main

if adc.force_init_mode(adc.INIT_VDD33) then
	print("adc reconfigured: reboot scheduled...")
	node.restart()
end

gpio.mode(LED_PIN, gpio.OUTPUT)

gpio.mode(TST_PIN1, gpio.INPUT)
gpio.mode(TST_PIN2, gpio.INPUT)
gpio.mode(TST_PIN3, gpio.INPUT)
gpio.mode(TST_PIN4, gpio.INPUT)

led_timer:register(1 * 1000, tmr.ALARM_AUTO, led_toggle)
adc_timer:register(1 * 1000, tmr.ALARM_AUTO, adc_reader)
pin_timer:register(1 * 1000, tmr.ALARM_AUTO, pin_reader)

print("test ready: use test_help() to list supported tests")
