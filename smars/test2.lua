-- SPDX-License-Identifier: GPL-3.0
--
-- Based on HC-SR04 NodeMCU examples by Vinicius Serafim
-- See: https://github.com/vsserafim/hcsr04-nodemcu
--
-- Copyright 2016, Vinícius Serafim <vinicius@serafim.eti.br>
-- Copyright 2019, Matyukevich Sergey <geomatsi@gmail.com>
--

--
-- modules
--

local m = require("gpio_motors")

--
-- settings
--

dofile("settings.lua")

--
-- LED
--

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
	led_toggle()

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

--
-- WIFI
--

local function wifi_connect_event(conn)
  print("Connected to AP(" .. conn.SSID .. ")...")
end

local function wifi_ip_addr_event(conn)
  print("Obtained IP(" .. conn.IP .. ")...")
  ws:connect(WS_URL)
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
-- WebSocket
--

local function ws_conn(ws)
  print('ws_conn: connected')
end

local function starts_with(str, start)
	   return str:sub(1, #start) == start
end

local function ws_recv(ws, msg, opcode)
	print('ws_recv: message: ', msg)
	print('ws_recv: opcode ', opcode)

	-- process server command
	if starts_with(msg, "stop") then
		print("stop")
		m.stop()
	elseif starts_with(msg, "fwd") then
		print("forward")
		m.fwd()
	elseif starts_with(msg, "rwd") then
		print("backward")
		m.rev()
	elseif starts_with(msg, "rotl") then
		print("rotate left")
		m.left()
	elseif starts_with(msg, "rotr") then
		print("rotate right")
		m.right()
	elseif starts_with(msg, "dist") then
		local resp = string.format("%d", distance * 100)
		print("distance: ", resp)
		ws:send(resp)
	else
		print('unknown command: ', msg)
	end
end

local function create_ws_reconnect(ws)
  return function()
    print("WS reconnect...")
    ws:connect(WS_URL)
  end
end

local function ws_close(ws, status)
  print('ws_close: status ', status)
  tmr.create():alarm(5 * 1000, tmr.ALARM_SINGLE, create_ws_reconnect(ws))
end

--
-- MAIN
--

-- configure motors

m.init(LFWD_PIN, LREV_PIN, RFWD_PIN, RREV_PIN)

-- configure LED

gpio.mode(LED_PIN, gpio.OUTPUT)

-- configure HC-SR04 ultrasound sensor

gpio.mode(TRIG_PIN, gpio.OUTPUT)
gpio.mode(ECHO_PIN, gpio.INT)
tm = tmr.create()
tm:register(READING_INTERVAL, tmr.ALARM_AUTO, trigger)
gpio.trig(ECHO_PIN, "both", echo_callback)
measure()

-- connect to ws server

ws = websocket.createClient()
ws:config({headers={['User-Agent']='SMARS'}})
ws:on('connection', ws_conn)
ws:on('receive', ws_recv)
ws:on('close', ws_close)
print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=WIFI_SSID, pwd=WIFI_PASS})
