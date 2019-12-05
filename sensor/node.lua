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

-- MQTT

local function create_mqtt_action_callback(client)
  return function()
    print("MQTT publish...")

    local free = string.format("%d", bit.rshift(node.heap(), 10))
    local ret1 = client:publish(MQTT_FREE, free, 0, 0)

    local rssi = wifi.sta.getrssi()
    if (rssi ~= nil) then
      rssi = string.format("%d", rssi)
    else
      rssi = "none"
    end
    local ret2 = client:publish(MQTT_RSSI, rssi, 0, 0)

    if (ret1 and ret2) then
	    tmr.create():alarm(5 * 1000, tmr.ALARM_SINGLE, create_mqtt_action_callback(client))
    end
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

-- main

m = mqtt.Client("test", 120)
m:on("offline", mqtt_reconnect)

gpio.mode(LED_PIN, gpio.OUTPUT)
tmr.create():alarm(1 * 1000, tmr.ALARM_AUTO, toggle_led)

print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=WIFI_SSID, pwd=WIFI_PASS})