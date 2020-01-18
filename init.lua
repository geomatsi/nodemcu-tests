-- simple command line tools

function help()
	print("ls: list files in root directory")
	print("purge: clear files from root directory")
	print("du: dump fsinfo free/used/total")
	print("free: free heap memory")
	print("reboot: reboot node")
	print("stop: stop autostart removing main.lua")
end

function ls()
	for k,v in pairs(file.list()) do
		print(k, v .. ' bytes')
	end
end

function purge()
	for k,v in pairs(file.list()) do
		file.remove(k)
	end
end

function du()
	local f, u, t = file.fsinfo()
	f = bit.rshift(f, 10)
	u = bit.rshift(u, 10)
	t = bit.rshift(t, 10)
	print('free: ', f .. ' kB')
	print('used: ', u .. ' kB')
	print('total: ', t .. ' kB')
end

function free()
	print(bit.rshift(node.heap(), 10) .. ' kB')
end

function reboot()
	node.restart()
end

function stop()
	file.remove("main.lua")
end

local function startup()
	if file.open("main.lua") == nil then
		print("main.lua deleted or renamed: stop here")
	else
		print("Continue startup")
		file.close("main.lua")
		dofile("main.lua")
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
