-- SPDX-License-Identifier: GPL-3.0
--
-- Copyright 2020, Matyukevich Sergey <geomatsi@gmail.com>
--

--
-- modules
--

local m = require("pwm_motors")

--
-- settings
--

dofile("settings.lua")

--
-- MAIN
--

-- configure motors

m.init(LFWD_PIN, LREV_PIN, RFWD_PIN, RREV_PIN)

F = m.fwd
B = m.rev
H = m.stop
R = m.right
L = m.left
S = m.speed

print("ready...")
