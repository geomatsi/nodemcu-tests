--
function ls()
	for k,v in pairs(file.list()) do
		print (k)
	end
end

-- init message
print('MAC: ', wifi.sta.getmac())
print('chip: ', node.chipid())
print('heap: ', node.heap())

-- setup wifi
-- dofile("wifi.lua")
