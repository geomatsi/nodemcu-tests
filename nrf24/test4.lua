-- Example 2: nrf24 receiver
-- Features:
--  - dynamic payload length
--  - gpio irq trigger

r = require("nrf24")

r.nrf24_hw_init()
r.nrf24_init_node()

r.nrf24_stop_listening()
r.nrf24_set_channel(76)
r.nrf24_set_dynamic_payload()
r.nrf24_set_recv_address({0x45, 0x46, 0x43, 0x4c, 0x49})
r.nrf24_start_listening()

function receiver(level, when)
	local ready = r.nrf24_data_available()

	if (ready > 0) then
		data = r.nrf24_data_read()
		print("=> when: " .. when .. " len: " .. #data)
		print(unpack(data))
	end
end

gpio.mode(2, gpio.INT)
gpio.trig(2, "low", receiver)
