-- simple command line tools

function ls()
	for k,v in pairs(file.list()) do
		print (k, v .. ' bytes')
	end
end

function du()
	local f, u, t = file.fsinfo()
	f = bit.rshift(f, 10)
	u = bit.rshift(u, 10)
	t = bit.rshift(t, 10)
	print ('free: ', f .. ' kB')
	print ('used: ', u .. ' kB')
	print ('total: ', t .. ' kB')
end

function free()
	print (bit.rshift(node.heap(), 10) .. ' kB')
end

function stop()
	file.remove("test.lua")
end

local function startup()
	if file.open("test.lua") == nil then
		print("test.lua deleted or renamed: stop here")
	else
		print("Continue startup")
		file.close("test.lua")
		dofile("test.lua")
	end
end

-- init message

print('Chip ID: ', node.chipid())
print('Flash ID: ', node.flashid())
print('Flash size (kB): ', bit.rshift(node.flashsize(), 10))
print('Available heap (kB): ', bit.rshift(node.heap(), 10))

print("Ready to start...") 
print("You have 5 seconds to abort...")
print("Run stop() to abort...")
print("Waiting...")

tmr.create():alarm(5 * 1000, tmr.ALARM_SINGLE, startup)
