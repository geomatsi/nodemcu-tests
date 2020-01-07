--
-- websocket test
--

-- Settings

dofile("settings.lua")

-- LED

local function toggle_led()
  local val = gpio.read(LED_PIN)
  if (val == 0) then
    gpio.write(LED_PIN, gpio.HIGH)
  else
    gpio.write(LED_PIN, gpio.LOW)
  end
end

-- WIFI

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

-- WebSocket

local function ws_conn(ws)
  print('ws_conn: connected')
end

local function ws_recv(ws, msg, opcode)
	print('ws_recv: message: ', msg)
	print('ws_recv: opcode ', opcode)
	-- very unsafe :-O
	assert(loadstring(msg))()
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

-- main

ws = websocket.createClient()
ws:config({headers={['User-Agent']='SMARS'}})
ws:on('connection', ws_conn)
ws:on('receive', ws_recv)
ws:on('close', ws_close)

gpio.mode(LED_PIN, gpio.OUTPUT)
tmr.create():alarm(1 * 1000, tmr.ALARM_AUTO, toggle_led)

print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=WIFI_SSID, pwd=WIFI_PASS})
