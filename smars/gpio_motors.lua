-- SPDX-License-Identifier: GPL-3.0
--
-- Copyright 2020, Matyukevich Sergey <geomatsi@gmail.com>
--

--
-- GPIO motors
--

local modname = ...
local M = {}
_G[modname] = M

local LREV_PIN = 5
local LFWD_PIN = 6
local RREV_PIN = 7
local RFWD_PIN = 8

function M.fwd()
	gpio.write(LFWD_PIN, gpio.HIGH)
	gpio.write(LREV_PIN, gpio.LOW)

	gpio.write(RFWD_PIN, gpio.HIGH)
	gpio.write(RREV_PIN, gpio.LOW)
end

function M.rev()
	gpio.write(LFWD_PIN, gpio.LOW)
	gpio.write(LREV_PIN, gpio.HIGH)

	gpio.write(RFWD_PIN, gpio.LOW)
	gpio.write(RREV_PIN, gpio.HIGH)
end

function M.stop()
	gpio.write(LFWD_PIN, gpio.LOW)
	gpio.write(LREV_PIN, gpio.LOW)

	gpio.write(RFWD_PIN, gpio.LOW)
	gpio.write(RREV_PIN, gpio.LOW)
end

function M.right()
	gpio.write(LFWD_PIN, gpio.LOW)
	gpio.write(LREV_PIN, gpio.HIGH)

	gpio.write(RFWD_PIN, gpio.HIGH)
	gpio.write(RREV_PIN, gpio.LOW)
end

function M.left()
	gpio.write(LFWD_PIN, gpio.HIGH)
	gpio.write(LREV_PIN, gpio.LOW)

	gpio.write(RFWD_PIN, gpio.LOW)
	gpio.write(RREV_PIN, gpio.HIGH)
end

function M.init(right_fwd, right_rev, left_fwd, left_rev)
	RFWD_PIN = right_fwd
	RREV_PIN = right_rev
	LFWD_PIN = left_fwd
	LREV_PIN = left_rev

	gpio.mode(LFWD_PIN, gpio.OUTPUT)
	gpio.mode(LREV_PIN, gpio.OUTPUT)
	gpio.mode(RFWD_PIN, gpio.OUTPUT)
	gpio.mode(RREV_PIN, gpio.OUTPUT)

	M.stop()
end

return M