r = require("nrf24")

r.nrf24_hw_init()
r.nrf24_init_node()

r.nrf24_stop_listening()
r.nrf24_set_channel(76)
r.nrf24_set_xmit_address({0x45, 0x46, 0x43, 0x4c, 0x49})

r.nrf24_set_dynamic_payload()

r.nrf24_power_up()

function packet1()
	print ("xmit packet1...")
	r.nrf24_send_packet({0x1, 0x2, 0x3, 0x4, 0x5})
end

function packet2()
	print ("xmit packet2...")
	r.nrf24_send_packet({0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9})
end

tmr.alarm(0, 1000, tmr.ALARM_AUTO, packet1)
tmr.alarm(1, 5000, tmr.ALARM_AUTO, packet2)
