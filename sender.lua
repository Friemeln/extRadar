function wait(seconds)
  local start = os.time()
  repeat until os.time() > start + seconds
end

timestamp = 0
-- sendinginterval=0.02        --alle so viele Sekunden werden Spielinfos verschickt
sendinginterval=0         --alle so viele Sekunden werden Spielinfos verschickt

socket=require("socket")
udp=socket.udp()
udp:settimeout(0)
-- connect to UDP server

--ip auflösen evtl host = socket.dns.toip("Computername, zB Cerberos")
udp:setpeername ("192.168.188.10",14285)

while true do
  for line in io.lines("daten.log") do 
	  clientstring = line
	  timestamp = timestamp + 1
	  udp:send(clientstring)
    print(timestamp..": "..clientstring)
    -- wait(sendinginterval)
  end
    udp:send(">> UDP-Ende: <<")
end
