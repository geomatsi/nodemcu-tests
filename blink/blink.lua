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

-- main

gpio.mode(LED_PIN, gpio.OUTPUT)
tmr.create():alarm(1 * 1000, tmr.ALARM_AUTO, toggle_led)

print("Blink started...")
