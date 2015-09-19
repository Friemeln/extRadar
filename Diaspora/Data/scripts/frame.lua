--
-- with a great thx to "PoDo" and his script from http://www.hard-light.net/forums/index.php?topic=84132.0
--

-- nur alle sendinginterval Tick's werden Daten erfasst und gesendet
if mn.getMissionTime() > timestamp then

	timestamp = mn.getMissionTime() + sendinginterval

	if debug then
		udp:send("## onFrame: Anfang  ------------------------- ## "..timestamp)
		-- udp:send("## Timestamp: "..timestamp)

		-- alle hv.Globals werden ausgegeben:
		local i
		local i_max
		i=1
		i_max=#hv.Globals
		for i = 1, i_max, 1 do
			udp:send("## hv.Globals["..i.."] = "..hv.Globals[i])
		end
	end

	-- Init Spieler
	spieler={}
	spieler.plr=hv.Player
	-- plr ist vom typ Object???

	if spieler.plr:isValid() then

		spieler.shp = mn.getObjectFromSignature(spieler.plr:getSignature())

		if debug then
			udp:send("## Spieler-Infos:")
			udp:send("## Name 1  : "..spieler.plr.Name)
      udp:send("## Name 2  : "..ba.getCurrentPlayer():getName())
			udp:send("## Position: "..spieler.plr.Position["x"]..","..spieler.plr.Position["y"]..","..spieler.plr.Position["z"] )
			udp:send("## Schiff-Infos: #"..#spieler.shp)
			udp:send("## Name    : "..spieler.shp.Name)
			udp:send("## Position: "..spieler.shp.Position[1]..","..spieler.shp.Position[2]..","..spieler.shp.Position[3] )
			-- udp:send("## Klasse.Name  : "..spieler.shp.Class.Name)
			-- udp:send("## K.ShortName  : "..spieler.shp.Class.ShortName)
			-- udp:send("## K.TypeString : "..spieler.shp.Class.TypeString)
			udp:send("## Shp.Team.Name: "..spieler.shp.Team.Name)
			-- udp:send("## Shp:getBreedN: "..spieler.shp:getBreedName() )
		end

		if spieler.shp:isValid() then
			
			-- Schiff Information ANFANG -------------------------------------------------------------------------
			
			shipinfo={}
			
			table.insert(shipinfo,"i")
			-- Position
			table.insert(shipinfo,spieler.plr.Position["x"])
			table.insert(shipinfo,spieler.plr.Position["z"])
			table.insert(shipinfo,spieler.plr.Position["y"])
			
			-- Spielername
			table.insert(shipinfo,spieler.plr.Name)
      table.insert(shipinfo,kennung)
			
			-- sammle Schiffsdaten
			table.insert(shipinfo,spieler.shp.Class.Name)
			--speed
			table.insert(shipinfo,math.floor(spieler.plr.Physics.Velocity:getMagnitude()))
			--life/damage aka hull integrity in %
			table.insert(shipinfo,math.floor(100/spieler.shp.HitpointsMax*spieler.shp.HitpointsLeft))
			-- table.insert(shipinfo,spieler.shp.Position[1]..","..spieler.shp.Position[3]..","..spieler.shp.Position[2]
			
			-- Schiff Information ENDE ---------------------------------------------------------------------------

            -- Radar Information START ---------------------------------------------------------------------------
			
			radarinfo={}
			local stv --zum zwischenspeichern des targets

			if mn.Debris ~= nil then
				for i= 1,#mn.Debris do
					if mn.Debris[i]:isValid() then
						--transform vector and get length
						local tpos = spieler.plr.Orientation:rotateVector(mn.Debris[i].Position - spieler.plr.Position)
						if spieler.plr.Target == mn.Debris[i] then --target zwischenspeichern
							stv = {"a",tpos.x,tpos.z,tpos.y,tpos:getMagnitude(),"1"}
						else
							local tmpradarblip={"d",tpos.x,tpos.z,tpos.y,tpos:getMagnitude(),"0","Debris"}
							
							-- Erstelle Tabelleneintrag für den "Müll"
							table.insert(radarinfo,table.concat(tmpradarblip,":|:"))
						end
					end
				end
			end

			if mn.Asteroids ~= nil then
				for i= 1,#mn.Asteroids do
					if mn.Asteroids[i]:isValid() then
						--transform vector and get length
						local tpos = spieler.plr.Orientation:rotateVector(mn.Asteroids[i].Position - spieler.plr.Position)
						if spieler.plr.Target == mn.Asteroids[i] then --target zwischenspeichern
							stv = {"d",tpos.x,tpos.z,tpos.y,tpos:getMagnitude(),"1"}
						else
							local tmpradarblip={"a",tpos.x,tpos.z,tpos.y,tpos:getMagnitude(),"0","Asteroid"}
							
							-- Erstelle Tabelleneintrag für die Asteroiden
							table.insert(radarinfo,table.concat(tmpradarblip,":|:"))
						end
					end
				end
			end

			if mn.Ships ~= nil then
				for i= 1,#mn.Ships do
					if mn.Ships[i]:isValid() and mn.Ships[i] ~= plr then
						--transform vector and get length
						local tpos = spieler.plr.Orientation:rotateVector(mn.Ships[i].Position - spieler.plr.Position)
						local iswrp="0"
						if mn.Ships[i]:isWarpingIn() then 
							local iswrp="1" 
						end
						local smass=math.floor(tb.ShipClasses[(mn.Ships[i].Class:getShipClassIndex()+1)].Model.Mass)

						if spieler.plr.Target == mn.Ships[i] then --target zwischenspeichern
							stv = {"s",
								tpos.x,tpos.z,tpos.y,tpos:getMagnitude(),
								"1",
								mn.Ships[i].Name, 
								mn.Ships[i].Team.Name,
								mn.Ships[i].Class.Name,
								iswrp,
								math.floor(100/mn.Ships[i].HitpointsMax*mn.Ships[i].HitpointsLeft),
								smass}
						else -- schiff ist kein target
							local tmpradarblip={"s",
								tpos.x,tpos.z,tpos.y,tpos:getMagnitude(), 
								"0", 
								mn.Ships[i].Name, 
								mn.Ships[i].Team.Name, 
								mn.Ships[i].Class.Name, 
								iswrp, 
								math.floor(100/mn.Ships[i].HitpointsMax*mn.Ships[i].HitpointsLeft),
								smass}
							
							-- Erstelle Tabelleneintrag für die Schiffe
							table.insert(radarinfo,table.concat(tmpradarblip,":|:"))
							
						end
					end
				end -- for

			end

			if stv then
				table.insert(radarinfo,table.concat(stv,":|:"))
			end
			
			-- Radar Information ENDE ---------------------------------------------------------------------------

			-- Die gesammelten Daten werden nun zum Client geschickt
			local clientstring=table.concat(
				{
					table.concat(shipinfo,":|:"),
					table.concat(radarinfo,"\n")
					-- , table.concat(wingmeninfo,"|")
					},"\n")

			--udp:sendto(clientstring, ip, destport)

			udp:send(clientstring)

		else
			udp:send("Err(frame.lua): spieler.shp not valid")
		end -- shp valid

	else
		udp:send("Err(frame.lua): spieler.plr not valid")
	end -- plr valid

end -- frame-tick