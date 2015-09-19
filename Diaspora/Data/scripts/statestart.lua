timestamp = 0

-- debug=true
debug=false

socket=require("socket")

-- alle so viele Sekunden werden Spielinfos verschickt
-- sendinginterval=0.02 
sendinginterval=0.1

udp=socket.udp()
udp:settimeout(0)
-- connect to UDP server

--ip auflösen evtl host = socket.dns.toip("Computername, zB Cerberos")
--udp:setpeername ("192.168.0.8",14285)
-- mein eigener Rechner
udp:setpeername ("192.168.188.10",14285)

-- Spielerkennung... 
kennung = ba.getCurrentPlayer():getName()
	
if debug then

	udp:send("## StateStart: Anfang  vvvvvvvvvvvvvvvvvvvvvvvvv ##")

	local i
	local i_max
	i=1
	i_max=#hv.Globals
	if i_max > 0 then
		for i = 1, i_max, 1 do
			udp:send("## hv.Globals["..i.."] = "..hv.Globals[i])
		end
	else
		udp:send("## i_max: "..i_max)
	end

	udp:send("getCurrentPlayer: "..kennung)

end

-- dir=require("io")
-- for dir in io.popen([[dir "." /b /ad]]):lines() do 
--   print(dir) 
--   udp:send(dir)
-- end



if debug then
	udp:send("## StateStart: Ende    ^^^^^^^^^^^^^^^^^^^^^^^^^ ##")
end