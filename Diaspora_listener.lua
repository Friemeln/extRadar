-----------------------------------------------------------------------------
-- TCP sample: Little program to dump lines received at a given port
-- LuaSocket sample files
-- Author: Diego Nehab
-- RCS ID: $Id: listener.lua,v 1.11 2005/01/02 22:44:00 diego Exp $
--
-- angepasst um udp-daten des Diaspora HUD-Servers auszugeben...
-- Johannes
-----------------------------------------------------------------------------
local socket = require("socket")

host = host or "*"
port = port or 14285
if arg then
	host = arg[1] or host
	port = arg[2] or port
end

lastclienstring = ":|||::|||::|||::|||:"

print("Binding to host '" ..host.. "' and port " ..port.. "...")

socket=require("socket")

udp = socket.udp()
udp:settimeout(0)
-- bind UDP to all local interfaces 
udp:setsockname("*",port)

while true do
	local new_clientstring,ip,port=udp:receivefrom()
	if new_clientstring == nil then
		--[[ 
		print("-- no Data --".." ["..ip.."]")
		break
		end
		]] 
	elseif new_clientstring == clientstring then
		-- keine neuen Daten
		print("-- no new Data --".." ["..ip.."]")
	else
		print(new_clientstring)
		-- print("")  
	end
	clientstring=new_clientstring
end

