-- SPDX-License-Identifier: GPL-3.0
--
-- Copyright 2020, Matyukevich Sergey <geomatsi@gmail.com>
--

--
-- PWM motors
--

local modname = ...
local M = {}
_G[modname] = M


local LREV_PIN = 5
local LFWD_PIN = 6
local RREV_PIN = 7
local RFWD_PIN = 8

local PWM_DUTY = 650

function M.fwd()
	pwm.start(LFWD_PIN)
	pwm.stop(LREV_PIN)

	pwm.start(RFWD_PIN)
	pwm.stop(RREV_PIN)
end

function M.rev()
	pwm.stop(LFWD_PIN)
	pwm.start(LREV_PIN)

	pwm.stop(RFWD_PIN)
	pwm.start(RREV_PIN)
end

function M.stop()
	pwm.stop(LFWD_PIN)
	pwm.stop(LREV_PIN)

	pwm.stop(RFWD_PIN)
	pwm.stop(RREV_PIN)
end

function M.right()
	pwm.stop(LFWD_PIN)
	pwm.start(LREV_PIN)

	pwm.start(RFWD_PIN)
	pwm.stop(RREV_PIN)
end

function M.left()
	pwm.start(LFWD_PIN)
	pwm.stop(LREV_PIN)

	pwm.stop(RFWD_PIN)
	pwm.start(RREV_PIN)
end

function M.speed(value)
	if value > 1023
	then
		value = 1023
	end

	if value < 0
	then
		value = 0
	end

	PWM_DUTY = value

	pwm.setup(LREV_PIN, 1000, PWM_DUTY)
	pwm.setup(LFWD_PIN, 1000, PWM_DUTY)
	pwm.setup(RREV_PIN, 1000, PWM_DUTY)
	pwm.setup(RFWD_PIN, 1000, PWM_DUTY)
end

function M.init(right_fwd, right_rev, left_fwd, left_rev)
	RFWD_PIN = right_fwd
	RREV_PIN = right_rev
	LFWD_PIN = left_fwd
	LREV_PIN = left_rev

	pwm.setup(LREV_PIN, 1000, PWM_DUTY)
	pwm.setup(LFWD_PIN, 1000, PWM_DUTY)
	pwm.setup(RREV_PIN, 1000, PWM_DUTY)
	pwm.setup(RFWD_PIN, 1000, PWM_DUTY)
end

return M