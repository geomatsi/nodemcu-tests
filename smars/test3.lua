-- SPDX-License-Identifier: GPL-3.0
--
-- Copyright 2020, Matyukevich Sergey <geomatsi@gmail.com>
--

--
-- PWM motors
--

LRWD_PIN = 5
LFWD_PIN = 6
RRWD_PIN = 7
RFWD_PIN = 8

-- forward
function f()
	pwm.start(LFWD_PIN)
	pwm.stop(LRWD_PIN)

	pwm.start(RFWD_PIN)
	pwm.stop(RRWD_PIN)
end

-- rotate
function b()
	pwm.stop(LFWD_PIN)
	pwm.start(LRWD_PIN)

	pwm.stop(RFWD_PIN)
	pwm.start(RRWD_PIN)
end

-- stop
function s()
	pwm.stop(LFWD_PIN)
	pwm.stop(LRWD_PIN)

	pwm.stop(RFWD_PIN)
	pwm.stop(RRWD_PIN)
end

-- left
function l()
	pwm.stop(LFWD_PIN)
	pwm.start(LRWD_PIN)

	pwm.start(RFWD_PIN)
	pwm.stop(RRWD_PIN)
end

-- right
function r()
	pwm.start(LFWD_PIN)
	pwm.stop(LRWD_PIN)

	pwm.stop(RFWD_PIN)
	pwm.start(RRWD_PIN)
end

--
-- LED
--

LED_PIN = 4

function led_toggle()
	local val = gpio.read(LED_PIN)
	if (val == 0) then
		gpio.write(LED_PIN, gpio.HIGH)
	else
		gpio.write(LED_PIN, gpio.LOW)
	end
end

--
-- MAIN
--

pwm.setup(LRWD_PIN, 1000, 650)
pwm.setup(LFWD_PIN, 1000, 650)
pwm.setup(RRWD_PIN, 1000, 650)
pwm.setup(RFWD_PIN, 1000, 650)

print("ready...")
