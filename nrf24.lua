-- nRF24 module

local modname = ...
local M = {}
_G[modname] = M

--
-- module constants
--

-- nRF24 commands
local R_REGISTER	= 0x00
local W_REGISTER	= 0x20
local REGISTER_MASK	= 0x1F
local W_TX_PAYLOAD	= 0xA0
local FLUSH_TX		= 0xE1
local FLUSH_RX		= 0xE2
local NOP		= 0xFF
local R_RX_PL_WID	= 0x60
local R_RX_PAYLOAD	= 0x61
--local ACTIVATE	= 0x50
--local W_ACK_PAYLOAD	= 0xA8
--local REUSE_TX_PL	= 0xE3

-- nRF24 register map
local CONFIG      = 0x00
local SETUP_RETR  = 0x04
local RF_CH       = 0x05
local RF_SETUP    = 0x06
local STATUS      = 0x07
local RX_ADDR_P0  = 0x0A
local TX_ADDR     = 0x10
local RX_PW_P0    = 0x11
local DYNPD       = 0x1C
local FEATURE     = 0x1D
local EN_RXADDR   = 0x02
local FIFO_STATUS = 0x17
--local EN_AA       = 0x01
--local SETUP_AW    = 0x03
--local OBSERVE_TX  = 0x08
--local CD          = 0x09
--local RX_ADDR_P1  = 0x0B
--local RX_ADDR_P2  = 0x0C
--local RX_ADDR_P3  = 0x0D
--local RX_ADDR_P4  = 0x0E
--local RX_ADDR_P5  = 0x0F
--local RX_PW_P1    = 0x12
--local RX_PW_P2    = 0x13
--local RX_PW_P3    = 0x14
--local RX_PW_P4    = 0x15
--local RX_PW_P5    = 0x16

-- register bits
local ARD		= 4
local ARC		= 0
local RF_PWR_LOW	= 1
local RF_PWR_HIGH	= 2
local RF_DR_LOW		= 5
local RF_DR_HIGH	= 3
local EN_CRC		= 3
local CRCO		= 2
local RX_DR		= 6
local TX_DS		= 5
local MAX_RT		= 4
local PRIM_RX		= 0
local PWR_UP		= 1
local EN_DPL		= 2
local ERX_P0		= 0
local RX_EMPTY		= 0
--local ERX_P1		= 1
--local ERX_P2		= 2
--local ERX_P3		= 3
--local ERX_P4		= 4
--local ERX_P5		= 5

--
-- module fields
--

local PAYLOAD = 0
local CE_PIN = 3
local CS_PIN = 4

--
-- module methods
--

function M.nrf24_hw_init()
	spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 80, spi.FULLDUPLEX)
	-- CE pin
	gpio.mode(CE_PIN, gpio.OUTPUT)
	gpio.write(CE_PIN, gpio.HIGH)
	-- CS pin
	gpio.mode(CS_PIN, gpio.OUTPUT)
	gpio.write(CS_PIN, gpio.HIGH)
end

local function nrf24_ce(value)
	if (value > 0) then
		gpio.write(CE_PIN, gpio.HIGH)
	else
		gpio.write(CE_PIN, gpio.LOW)
	end
end

local function nrf24_csn(value)
	if (value > 0) then
		gpio.write(CS_PIN, gpio.HIGH)
	else
		gpio.write(CS_PIN, gpio.LOW)
	end
end

local function reverse_addr(addr_in)
	---- address is 5bytes length
	---- address is written inversely
	addr_out = {}
	for i = 1, 5 do
		if (addr_in[5 - i + 1] ~= nil) then
			addr_out[i] = addr_in[5 - i + 1]
		else
			addr_out[i] = 0x0
		end
	end

	return addr_out
end


function M.nrf24_send_cmd(cmd)
	nrf24_csn(0)
	_, ret = spi.send(1, cmd)
	nrf24_csn(1)
	return ret
end

function M.nrf24_send_req(req)
	nrf24_csn(0)
	_, _, rsp = spi.send(1, req, 0xff)
	nrf24_csn(1)
	return rsp
end

function M.nrf24_msend_req(req, len)
	input = {}
	for i = 1, len do
		input[i] = 0xff
	end

	nrf24_csn(0)
	_, _, output = spi.send(1, req, input)
	nrf24_csn(1)

	return output
end

function M.nrf24_msend_cmd(cmd, values)
	nrf24_csn(0)
	_, ret, _ = spi.send(1, cmd, values)
	nrf24_csn(1)
	return ret
end

function M.nrf24_get_status()
	nrf24_csn(0)
	_, status = spi.send(1, NOP)
	nrf24_csn(1)
	return status
end

function M.nrf24_read_register(reg)
	nrf24_csn(0)
	_, _, ret = spi.send(1, bit.bor(R_REGISTER, bit.band(REGISTER_MASK, reg)), 0xff)
	nrf24_csn(1)
	return ret
end

function M.nrf24_mread_register(reg, len)
	input = {}
	for i = 1, len do
		input[i] = 0xff
	end
	nrf24_csn(0)
	_, _, output = spi.send(1, bit.bor(R_REGISTER, bit.band(REGISTER_MASK, reg)), input)
	nrf24_csn(1)
	return output
end

function M.nrf24_write_register(reg, value)
	nrf24_csn(0)
	_, ret, _ = spi.send(1, bit.bor(W_REGISTER, bit.band(REGISTER_MASK, reg)), value)
	nrf24_csn(1)
	return ret
end

function M.nrf24_mwrite_register(reg, values)
	nrf24_csn(0)
	_, ret, _ = spi.send(1, bit.bor(W_REGISTER, bit.band(REGISTER_MASK, reg)), values)
	nrf24_csn(1)
	return ret
end

function M.nrf24_stop_listening()
	config = M.nrf24_read_register(CONFIG)
	config = bit.band(config, bit.bnot(bit.lshift(1, PRIM_RX)))
	M.nrf24_write_register(CONFIG, config)

	M.nrf24_mwrite_register(RX_ADDR_P0, {0x0, 0x0, 0x0, 0x0, 0x0})
	M.nrf24_mwrite_register(TX_ADDR, {0x0, 0x0, 0x0, 0x0, 0x0})
end

function M.nrf24_start_listening()
	config = M.nrf24_read_register(CONFIG)
	config = bit.bor(config, bit.lshift(1, PRIM_RX), bit.lshift(1, PWR_UP))
	M.nrf24_write_register(CONFIG, config)

	status = bit.bor(bit.lshift(1, RX_DR), bit.lshift(1, TX_DS), bit.lshift(1, MAX_RT))
	M.nrf24_write_register(STATUS, status)

	nrf24_ce(1);
	tmr.delay(130)
end

function M.nrf24_set_xmit_address(address)
	---- address is 5bytes length
	---- address is written inversely
	addr = reverse_addr(address)

	M.nrf24_mwrite_register(RX_ADDR_P0, addr)
	M.nrf24_mwrite_register(TX_ADDR, addr)
end

-- TODO: support all 6 rx pipes
function M.nrf24_set_recv_address(address)
	---- address is 5bytes length
	---- address is written inversely
	addr = reverse_addr(address)

	M.nrf24_mwrite_register(RX_ADDR_P0, addr)

	pipes = M.nrf24_read_register(EN_RXADDR)
	pipes = bit.bor(pipes, bit.lshift(1, ERX_P0))
	M.nrf24_write_register(EN_RXADDR, pipes)
end

-- TODO: support all 6 rx pipes
function M.nrf24_data_available()
	status = M.nrf24_get_status()
	result = M.nrf24_read_register(FIFO_STATUS)
	data_ready = 0

	if (bit.isclear(result, RX_EMPTY)) then
		-- TODO: get pipe which received data
		-- pipe_num = ( status >> RX_P_NO ) & BIN(111);

		M.nrf24_write_register(STATUS, bit.lshift(1, RX_DR))

		if (bit.isset(status, TX_DS)) then
			M.nrf24_write_register(STATUS, bits.lshift(1, TX_DS))
		end

		data_ready = 1
	end

	return data_ready
end

function M.nrf24_get_dynamic_payload_size()

	size = M.nrf24_send_req(R_RX_PL_WID)

	if (size > 32) then
		-- radio noise received, dropping
		M.nrf24_send_cmd(FLUSH_RX)
		size = 0
	end

	return size
end

-- TODO: support all 6 rx pipes
function M.nrf24_data_read()

	if (PAYLOAD == 0) then
		len = M.nrf24_get_dynamic_payload_size()
	else
		len = PAYLOAD
	end

	output = M.nrf24_msend_req(R_RX_PAYLOAD, len)
	return output
end

function M.nrf24_set_payload_size(payload_size)
	PAYLOAD = payload_size

	if (PAYLOAD > 32) then
		PAYLOAD = 32
	end

	if (PAYLOAD < 1) then
		PAYLOAD = 1
	end

	M.nrf24_write_register(RX_PW_P0, PAYLOAD)
end

function M.nrf24_set_dynamic_payload()
	PAYLOAD = 0

	-- FIXME: we may need to enable writing to FEATURE register

	value = M.nrf24_read_register(FEATURE)
	value = bit.bor(value, bit.lshift(1, EN_DPL))
	M.nrf24_write_register(FEATURE, value)

	-- enable dynamic payload for all the pipes
	M.nrf24_write_register(DYNPD, 0x3f)
end

function M.nrf24_set_channel(channel)
	M.nrf24_write_register(RF_CH, channel)
end

function M.nrf24_power_up()
	config = M.nrf24_read_register(CONFIG);
	config = bit.bor(config, bit.lshift(1, PWR_UP))
	M.nrf24_write_register(CONFIG, config)
end

function M.nrf24_send_packet(data)
	xmit_data = {}
	xmit_len = 32

	-- set packet length for non-dynamic payload
	if PAYLOAD > 0 then
		xmit_len = PAYLOAD
	end

	for i = 1, xmit_len do
		if (data[i] ~= nil) then
			xmit_data[i] = data[i]
		else
			if PAYLOAD == 0 then
				break
			end
			xmit_data[i] = 0x0
		end
	end

	-- write packet to FIFO
	M.nrf24_msend_cmd(W_TX_PAYLOAD, xmit_data)

	-- xmit packet
	nrf24_ce(1);
	tmr.delay(15)
	nrf24_ce(0);
end

-- simple client node setup
function M.nrf24_init_node()
	nrf24_ce(0)

	-- let the radio some time to warm-up
	tmr.delay(5000)

	-- set maximum PA level
	setup = M.nrf24_read_register(RF_SETUP)
	setup = bit.bor(setup, bit.lshift(1, RF_PWR_LOW), bit.lshift(1, RF_PWR_HIGH))
	M.nrf24_write_register(RF_SETUP, setup)

	-- set data rate to 1Mbps
	setup = M.nrf24_read_register(RF_SETUP)
	setup = bit.band(setup, bit.bnot(bit.bor(bit.lshift(1, RF_DR_LOW), bit.lshift(1, RF_DR_HIGH))))
	M.nrf24_write_register(RF_SETUP, setup)

	-- set 16bit CRC
	config = M.nrf24_read_register(CONFIG)
	config = bit.bor(config, bit.lshift(1, EN_CRC), bit.lshift(1, CRCO))
	M.nrf24_write_register(CONFIG, config)

	-- configure retries
	M.nrf24_write_register(SETUP_RETR, bit.bor(bit.lshift(bit.band(10, 0xf), ARD), bit.lshift(bit.band(5, 0xf), ARC)))

	-- disable dynamic payloads
	M.nrf24_write_register(DYNPD, 0);

	-- reset current status
	M.nrf24_write_register(STATUS, bit.bor(bit.lshift(1, RX_DR), bit.lshift(1, TX_DS), bit.lshift(1, MAX_RT)))

	-- flush buffers
	M.nrf24_send_cmd(FLUSH_RX)
	M.nrf24_send_cmd(FLUSH_TX)
end


return M
