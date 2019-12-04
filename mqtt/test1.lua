m = mqtt.Client("test", 120)
t = tmr.create()

m:on("connect", function(client)
	print ("connected")
end)

m:on("offline", function(client)
	print ("offline")
  	t:stop()
  	t:unregister()
end)

m:connect("192.168.1.102", 1883, 0,
function(client)
  print("connected")
  t:register(5000, tmr.ALARM_AUTO, function()
	  local rssi = string.format("%d", wifi.sta.getrssi())
	  client:publish("/wemos/rssi", rssi, 0, 0,
	  function(client)
		  print("sent")
	  end)
  end)
  t:start()
end,
function(client, reason)
  print("failed reason: " .. reason)
end)

m:close();
