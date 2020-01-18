-- SPDX-License-Identifier: GPL-3.0
--
-- Based on HC-SR04 NodeMCU examples by Vinicius Serafim
-- See: https://github.com/vsserafim/hcsr04-nodemcu
--
-- Copyright 2016, Vinícius Serafim <vinicius@serafim.eti.br>
-- Copyright 2019, Matyukevich Sergey <geomatsi@gmail.com>
--

--
-- motors
--

LRWD_PIN = 5
LFWD_PIN = 6
RRWD_PIN = 7
RFWD_PIN = 8

-- forward
function smars_forward()
	gpio.write(LFWD_PIN, gpio.HIGH)
	gpio.write(LRWD_PIN, gpio.LOW)

	gpio.write(RFWD_PIN, gpio.HIGH)
	gpio.write(RRWD_PIN, gpio.LOW)
end

-- rotate
function smars_rotate()
	gpio.write(LFWD_PIN, gpio.LOW)
	gpio.write(LRWD_PIN, gpio.HIGH)

	gpio.write(RFWD_PIN, gpio.HIGH)
	gpio.write(RRWD_PIN, gpio.LOW)
end

-- stop
function smars_stop()
	gpio.write(LFWD_PIN, gpio.LOW)
	gpio.write(LRWD_PIN, gpio.LOW)

	gpio.write(RFWD_PIN, gpio.LOW)
	gpio.write(RRWD_PIN, gpio.LOW)
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
-- ultrasound
--

TRIG_PIN = 1
ECHO_PIN = 2

-- trig interval in microseconds (minimun is 10, see HC-SR04 documentation)
TRIG_INTERVAL = 15
-- maximum distance in meters
MAXIMUM_DISTANCE = 10
-- minimum reading interval with 20% of margin
READING_INTERVAL = math.ceil(((MAXIMUM_DISTANCE * 2 / 340 * 1000) + TRIG_INTERVAL) * 1.2)
-- number of readings to average
AVG_READINGS = 3
-- CONTINUOUS MEASURING
CONTINUOUS = true

-- initialize global variables
time_start = 0
time_stop = 0
distance = 0
readings = {}

-- start a measure cycle
function measure()
	readings = {}
	tm:start()
end

-- called when measure is done
function done_measuring()
	-- m-to-cm
	local dist = distance * 100
	print("Distance: "..string.format("%.3f", dist).." Readings: "..#readings)
	led_toggle()

	if dist < 15.0 then
		print "rotate..."
		smars_rotate()
	else
		print "forward..."
		smars_forward()
	end

	if CONTINUOUS then
		node.task.post(measure)
	end
end

-- distance calculation, called by the echo_callback function on falling edge.
function calculate()

	-- echo time (or high level time) in seconds
	local echo_time = (time_stop - time_start) / 1000000

	-- got a valid reading
	if echo_time > 0 then
		-- distance = echo time (or high level time) in seconds * velocity of sound (340M/S) / 2
		local distance = echo_time * 340 / 2
		table.insert(readings, distance)
	end

	-- got all readings
	if #readings >= AVG_READINGS then
		tm:stop()

		-- calculate the average of the readings
		distance = 0
		for k,v in pairs(readings) do
			distance = distance + v
		end
		distance = distance / #readings
		
		node.task.post(done_measuring)
	end
end

-- echo callback function called on both rising and falling edges
function echo_callback(level)
	if level == 1 then
		-- rising edge (low to high)
		time_start = tmr.now()
	else
		-- falling edge (high to low)
		time_stop = tmr.now()
		calculate()
	end
end

-- send trigger signal
function trigger()
	gpio.write(TRIG_PIN, gpio.HIGH)
	tmr.delay(TRIG_INTERVAL)
	gpio.write(TRIG_PIN, gpio.LOW)
end

-- configure HC-SR04 pins
gpio.mode(TRIG_PIN, gpio.OUTPUT)
gpio.mode(ECHO_PIN, gpio.INT)

-- configure motor pins
gpio.mode(LFWD_PIN, gpio.OUTPUT)
gpio.mode(LRWD_PIN, gpio.OUTPUT)
gpio.mode(RFWD_PIN, gpio.OUTPUT)
gpio.mode(RRWD_PIN, gpio.OUTPUT)

-- configure LED pin
gpio.mode(LED_PIN, gpio.OUTPUT)

-- stop motors
smars_stop()

-- trigger timer
tm = tmr.create()
tm:register(READING_INTERVAL, tmr.ALARM_AUTO, trigger)

-- set callback function to be called both on rising and falling edges
gpio.trig(ECHO_PIN, "both", echo_callback)

-- start
measure()
