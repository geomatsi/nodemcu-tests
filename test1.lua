-- Example 1: nrf24 transmitter
-- Features: fixed payload length

r = require("nrf24")

r.nrf24_hw_init()
r.nrf24_init_node()

r.nrf24_stop_listening()
r.nrf24_set_channel(76)
r.nrf24_set_xmit_address({0x45, 0x46, 0x43, 0x4c, 0x49})

r.nrf24_set_payload_size(15)

r.nrf24_power_up()

function packet()
	print ("xmit packet...")
	r.nrf24_send_packet({0x1, 0x2, 0x3, 0x4, 0x5})
end

tmr.alarm(0, 1000, tmr.ALARM_AUTO, packet)
