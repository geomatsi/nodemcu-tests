-- simple command line tools

function ls()
	for k,v in pairs(file.list()) do
		print (k, v .. ' bytes')
	end
end

function du()
	f, u, t = file.fsinfo()
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

-- init message

print('Chip ID: ', node.chipid())
print('Flash ID: ', node.flashid())
print('Flash size (kB): ', bit.rshift(node.flashsize(), 10))
print('Available heap (kB): ', bit.rshift(node.heap(), 10))
