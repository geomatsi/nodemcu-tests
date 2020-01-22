-- SPDX-License-Identifier: GPL-3.0
--
-- Copyright 2019, Matyukevich Sergey <geomatsi@gmail.com>
--

--
-- modules
--

local m = require("gpio_motors")
local u = require("hc_sr_04")

--
-- settings
--

dofile("settings.lua")

--
-- LED
--

local function led_toggle()
	local val = gpio.read(LED_PIN)
	if (val == 0) then
		gpio.write(LED_PIN, gpio.HIGH)
	else
		gpio.write(LED_PIN, gpio.LOW)
	end
end

--
-- ultrasonic sensor callback
--

local function usound_cb(distance)
	-- m-to-cm
	local dist = distance * 100
	print("Distance: "..string.format("%.3f", dist))
	led_toggle()

	if dist < 15.0 then
		print "rotate..."
		m.left()
	else
		print "forward..."
		m.fwd()
	end
end

-- configure LED pin
gpio.mode(LED_PIN, gpio.OUTPUT)

-- configure motors
m.init(LFWD_PIN, LREV_PIN, RFWD_PIN, RREV_PIN)

-- configure ultrasonic sensor
u.HCSR04(TRIG_PIN, ECHO_PIN, 10, 3, true, usound_cb).measure()