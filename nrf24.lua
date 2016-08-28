--  instructions
local R_REGISTER	= 0x00
local W_REGISTER	= 0x20
local REGISTER_MASK = 0x1F
--local ACTIVATE      = 0x50
--local R_RX_PL_WID   = 0x60
--local R_RX_PAYLOAD  = 0x61
local W_TX_PAYLOAD  = 0xA0
--local W_ACK_PAYLOAD = 0xA8
local FLUSH_TX      = 0xE1
local FLUSH_RX      = 0xE2
--local REUSE_TX_PL   = 0xE3
--local NOP           = 0xFF

-- register map
local CONFIG      = 0x00
--local EN_AA       = 0x01
--local EN_RXADDR   = 0x02
--local SETUP_AW    = 0x03
local SETUP_RETR  = 0x04
local RF_CH       = 0x05
local RF_SETUP    = 0x06
local STATUS      = 0x07
--local OBSERVE_TX  = 0x08
--local CD          = 0x09
local RX_ADDR_P0  = 0x0A
--local RX_ADDR_P1  = 0x0B
--local RX_ADDR_P2  = 0x0C
--local RX_ADDR_P3  = 0x0D
--local RX_ADDR_P4  = 0x0E
--local RX_ADDR_P5  = 0x0F
local TX_ADDR     = 0x10
local RX_PW_P0    = 0x11
--local RX_PW_P1    = 0x12
--local RX_PW_P2    = 0x13
--local RX_PW_P3    = 0x14
--local RX_PW_P4    = 0x15
--local RX_PW_P5    = 0x16
--local FIFO_STATUS = 0x17
local DYNPD       = 0x1C
--local FEATURE     = 0x1D

-- register bits
local ARD			= 4
local ARC			= 0
local RF_PWR_LOW	= 1
local RF_PWR_HIGH	= 2
local RF_DR_LOW		= 5
local RF_DR_HIGH	= 3
local EN_CRC		= 3
local CRCO			= 2
local RX_DR			= 6
local TX_DS			= 5
local MAX_RT		= 4
local PRIM_RX		= 0
local PWR_UP		= 1

--
local CE_PIN = 3
local CS_PIN = 4

function nrf24_init()
	spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 80, spi.FULLDUPLEX)
	-- CE pin
	gpio.mode(CE_PIN, gpio.OUTPUT)
	gpio.write(CE_PIN, gpio.HIGH)
	-- CS pin
	gpio.mode(CS_PIN, gpio.OUTPUT)
	gpio.write(CS_PIN, gpio.HIGH)
end

function nrf24_ce(value)
	if (value > 0) then
		gpio.write(CE_PIN, gpio.HIGH)
	else
		gpio.write(CE_PIN, gpio.LOW)
	end
end

function nrf24_csn(value)
	if (value > 0) then
		gpio.write(CS_PIN, gpio.HIGH)
	else
		gpio.write(CS_PIN, gpio.LOW)
	end
end

function nrf24_send_cmd(cmd)
	nrf24_csn(0)
	_, ret = spi.send(1, cmd)
	nrf24_csn(1)
	return ret
end

function nrf24_writeout_cmd(cmd, values)
	nrf24_csn(0)
	_, ret, _ = spi.send(1, cmd, values)
	nrf24_csn(1)
	return ret
end

function nrf24_read_register(reg)
	nrf24_csn(0)
	_, _, ret = spi.send(1, bit.bor(R_REGISTER, bit.band(REGISTER_MASK, reg)), 0xff)
	nrf24_csn(1)
	return ret
end

function nrf24_readout_register(reg, n)
	input = {}
	for i = 1, n do
		input[i] = 0xff
	end
	nrf24_csn(0)
	_, _, output = spi.send(1, bit.bor(R_REGISTER, bit.band(REGISTER_MASK, reg)), input)
	nrf24_csn(1)
	return output
end

function nrf24_write_register(reg, value)
	nrf24_csn(0)
	_, ret, _ = spi.send(1, bit.bor(W_REGISTER, bit.band(REGISTER_MASK, reg)), value)
	nrf24_csn(1)
	return ret
end

function nrf24_writeout_register(reg, values)
	nrf24_csn(0)
	_, ret, _ = spi.send(1, bit.bor(W_REGISTER, bit.band(REGISTER_MASK, reg)), values)
	nrf24_csn(1)
	return ret
end

function nrf24_setup()
	nrf24_ce(0)

	-- let the radio some time to warm-up
	tmr.delay(5000)

	-- set ack timeouts
	nrf24_write_register(SETUP_RETR, bit.bor(bit.lshift(4, ARD), bit.lshift(15, ARC)))

	-- set maximum PA level
	setup = nrf24_read_register(RF_SETUP)
	setup = bit.bor(setup, bit.lshift(1, RF_PWR_LOW), bit.lshift(1, RF_PWR_HIGH))
	nrf24_write_register(RF_SETUP, setup)

	-- set data rate to 1Mbps
	setup = nrf24_read_register(RF_SETUP)
	setup = bit.band(setup, bit.bnot(bit.bor(bit.lshift(1, RF_DR_LOW), bit.lshift(1, RF_DR_HIGH))))
	nrf24_write_register(RF_SETUP, setup)

	-- set 16bit CRC
	config = nrf24_read_register(CONFIG)
	config = bit.bor(config, bit.lshift(1, EN_CRC), bit.lshift(1, CRCO))
	nrf24_write_register(CONFIG, config)

	-- disable dynamic payloads
	nrf24_write_register(DYNPD, 0);

	-- reset current status
	nrf24_write_register(STATUS, bit.bor(bit.lshift(1, RX_DR), bit.lshift(1, TX_DS), bit.lshift(1, MAX_RT)))

	-- set channel
	nrf24_write_register(RF_CH, 76)

	-- flush buffers
	nrf24_send_cmd(FLUSH_RX)
	nrf24_send_cmd(FLUSH_TX)

end

function nrf24_stop_listening()
	config = nrf24_read_register(CONFIG)
	config = bit.band(config, bit.bnot(bit.lshift(1, PRIM_RX)))
	nrf24_write_register(CONFIG, config)

	nrf24_writeout_register(RX_ADDR_P0, {0x0, 0x0, 0x0, 0x0, 0x0})
	nrf24_writeout_register(TX_ADDR, {0x0, 0x0, 0x0, 0x0, 0x0})
end

function nrf24_set_retries(delay, count)
	nrf24_write_register(SETUP_RETR, bit.bor(bit.lshift(bit.band(delay, 0xf), ARD), bit.lshift(bit.band(count, 0xf), ARC)))
end

function nrf24_open_writing_pipe(address, payload_size)
	-- set address
	nrf24_writeout_register(RX_ADDR_P0, address)
	nrf24_writeout_register(TX_ADDR, address)

	-- set payload size
	nrf24_write_register(RX_PW_P0, payload_size)
end

function nrf24_power_up()
	config = nrf24_read_register(CONFIG);
	config = bit.bor(config, bit.lshift(1, PWR_UP))
	nrf24_write_register(CONFIG, config)
end

-- FIXME: len must be equal to payload size
function nrf24_send_packet(data, len)
	-- write packet to FIFO
	nrf24_writeout_cmd(W_TX_PAYLOAD, data)

	-- xmit packet
    nrf24_ce(1);
	tmr.delay(15)
	nrf24_ce(0);
end

-- main cycle

nrf24_init()
nrf24_setup()

nrf24_stop_listening()
nrf24_set_retries(10, 5)
-- addr: EFCLI
-- FIXME: now reversed address should be passed to open_writing_pipe
nrf24_open_writing_pipe({0x49, 0x4c, 0x43, 0x46, 0x45}, 10)
nrf24_power_up()

while 1 do
	nrf24_send_packet({0x1, 0x1, 0x2, 0x2, 0x3, 0x3, 0x4, 0x4, 0x5, 0x5}, 10)
	print ("xmit packet...")
	tmr.delay(2000000)
end
