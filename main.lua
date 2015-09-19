--[[
                      Versuch einen DRADIS - Radar nachzuprogrammieren
                      ================================================
                      
                        Johannes Lummel für: www.twelve-colonies.de

V0.2: 
- Die Daten aller eingehenden UDP-Daten werden während love.update(dt) in einem Daten-Dictionary (?) zwischengespeichert
- das Daten-Dictionary wird in love.draw() ausgelesen und dargestellt.
  dabei wir ein Zähler runtergezählt um Objekte die nicht mehr existieren auszublenden.
  
]]


-- Skalierung der Dradis-Sprites (Raptor, Viper, Raider ...)
sx, sy = 0.5, 0.5


bgw = love.graphics.getWidth()
w2 = love.graphics.getWidth() / 2    -- halbe Window width
h2 = love.graphics.getHeight() / 2   -- halbe Window height

-- Maus Koordinaten
mx, my   = 0, 0

radarzoom = 0.2

-- Dictionary für die Radarkontakte
radar={}

-- Alles initialisieren für UDP-Empfang -- START -----------------
local socket = require("socket")

host = host or "*"
port = port or 14285
if arg then
  host = arg[1] or host
  port = arg[2] or port
end

radardaten = ""

print("Binding to host '" ..host.. "' and port " ..port.. "...")

udp = socket.udp()
udp:settimeout(0)
-- bind UDP to all local interfaces 
udp:setsockname("*",port)

-- Alles initialisieren für UDP-Empfang -- ENDE ------------------

--load our assets
function love.load()
  --load all assets here

  -- image = love.graphics.newImage("images/love-ball.png")
  img_backgrnd = love.graphics.newImage("resources/Dradis_bgr_"..bgw..".png")

  -- Cylonen / Feindlich
  img_unknown= love.graphics.newImage("resources/unknown.png")
  img_raider = love.graphics.newImage("resources/Raider1.png")
  --img_raider = love.graphics.newImage("resources/Raider2.png")

  -- Colonial Fleet
  img_raptor = love.graphics.newImage("resources/Raptor1.png")
  -- img_raptor = love.graphics.newImage("resources/Raptor.png")
  img_viper  = love.graphics.newImage("resources/Viper1.png")
  -- img_viper  = love.graphics.newImage("resources/Viper.png")
  img_batstar= love.graphics.newImage("resources/Battlestar.png")

  -- zivile Flotte
  img_civil= love.graphics.newImage("resources/Civil.png")


end

--update event
function love.update(dt)
  --do the maths

  dx, dy =0, 0
  mx, my = love.mouse.getPosition()  -- current position of the mouse

  local neue_radardaten, ip, port = udp:receivefrom()

  if neue_radardaten == nil then
    --[[ 
		print("-- no Data --".." ["..ip.."]")
		break
		end
		]] 

  elseif neue_radardaten == radardaten then
    -- keine neuen Daten
    print("-- no new Data --".." ["..ip.."]")
  else
    -- print("~~~~~~~~~~~~~~~~~~~~~~")
    -- print(neue_radardaten)
    --[[ 
    hier jetzt die Daten auswerten und in Koordinaten umwandeln...
    und zwar für alle Schiffe einen entsprechenden Eintrag in der Tabelle generieren
          
          image, x, y, Bezeichnung des Radarkontaktes
          ...
          
    ]]


-- den Clientstring in die einzelnen Datensätze aufspalten
    local tmpinfo=neue_radardaten:split("\n") 
    inf={}
    for k,rd_satz in pairs(tmpinfo) do

      tmp = rd_satz:split(":|:")
      if tmp[1]=="i" then
        --[[
      das Schiff in dem ein Spieler sitzt 
       1          2                   3                   4                 5             6           7     8
      "i:| :40.834884643555:| :106.28136444092:| :5.1890216127504e-005:| :Alpha 1:| :Viper Mark VII:| :2:|:100"
      ]]
        x=tmp[2]
        z=tmp[3]
        y=tmp[4]
        txt=tmp[5]

        if tmp[6]:match("Viper") == "Viper" then
          img=img_viper
        elseif tmp[6]:match("Raptor") == "Raptor" then
          img=img_raptor
        else
          img=img_civil
        end


      elseif tmp[1]=="s" then
        --[[
      die Radarinfos im allgemeinen
       1          2                   3                   4                 5             6        7         8            9             10    11
      "s:| :-52.482036590576:| :22.753707885742:| :-0.29745256900787:| :57.203006744385:| :0:| :Alpha 2:| :Friendly:| :Viper Mark VII:| :0:| :100:|:"
      ]]

        -- suche anhand von Feld9 das richtige Icon
        if tmp[9]:match("Raider") == "Raider" then
          img=img_raider
        elseif tmp[9]:match("Viper") == "Viper" then
          img=img_viper
        elseif tmp[9]:match("Raptor") == "Raptor" then
          img=img_raptor
        elseif tmp[9]:match("Battlestar") == "Battlestar" then
          img=img_batstar
        else
          if tmp[8]:match("Friendly") == "Friendly" then
            img=img_civil
          else
            img=img_unknown
          end
        end
        x=tmp[2]
        y=tmp[3]
        txt=tmp[7]
      end

      -- Das Dictionary wird mit Inhalt gefüllt
      --[[
      x,y : die Koordinaten des Kontakt
      txt : der Typ des Kontakt
      img : die Imagedaten 
      xx  : nach xx love.draw()-Zyklen ist dieser Eintrag ungültig.
    ]]
      print("Radar["..txt.."] = {"..x..","..y..","..txt..", ... }")
      radar[txt] = {x*sx, y*sy, txt, img, 128}
    end
    radardaten=neue_radardaten
  end -- endif Auswertung ob neue Radardaten vorhanden sind

end


--draw display
function love.draw()
  --describe how you want/what to draw.

  -- draw background
  love.graphics.draw(img_backgrnd, 0, 0, 0, bgh, bgh)

  -- Draw Infos.
  if radardaten then 
    -- love.graphics.print("Radar: " .. radardaten,   10, 150)
  else
    -- love.graphics.print("Radar: " .. "NIL",   10, 15)
  end
  love.graphics.print("mx, my: " .. mx .. ", " .. my , 10, 30)
  love.graphics.print("Zoom    : " .. radarzoom  , 10, 45)
  -- love.graphics.print("vx, vy: " .. vx .. ", " .. vy,  10, 60)
  -- love.graphics.print("      : " .. ,    10, 75)
  -- love.graphics.print("dx, dy: " .. dx.. ", " .. dy,  10, 90)

  love.graphics.setColor(64, 64, 64)
  -- Hilfskreuz durch die Bildschirmhälfte
  love.graphics.line(50, h2, w2*2-50, h2)
  love.graphics.line(w2, 50, w2, h2*2-50)

  -- Hilfskreuz durch die Mausposition
  --[[
  love.graphics.setColor(0, 255, 0)
  love.graphics.line(0, my, w2*2, my)
  love.graphics.line(mx, 0, mx, h2*2)
  ]]

  love.graphics.setColor(255, 255, 255)

--[[ das Radar-Dictionary wird ausgewertet... 
     radar[txt] = {x, y, txt, img, 16}
  ]]
  for k,tmp in pairs(radar) do
    d=tmp[5]-1
    if d > 32 then
      -- Radardaten ausgeben
      x = w2 + tmp[1] * radarzoom
      y = h2 - tmp[2] * radarzoom
      love.graphics.draw(tmp[4],  x, y, 0, sx, sy, 22, 25) -- die Mittelpunktkoordinaten stimmen nicht mehr wirklich :-((
      love.graphics.print(tmp[3], x, y)
      tmp[5]=d
    elseif d > 0 then
      if (d%4) == 1 then
        -- Radardaten ausgeben aber blinkend 
        x = w2 + tmp[1] * radarzoom
        y = h2 - tmp[2] * radarzoom
        love.graphics.draw(tmp[4],  x, y, 0, sx, sy, 22, 25) -- die Mittelpunktkoordinaten stimmen nicht mehr wirklich :-((
        love.graphics.print(tmp[3], x, y)
        tmp[5]=d
      end 
    else
      -- eigentlich jetzt den Datensatz löschen...
      tmp={}

    end



    --[[
  love.graphics.draw(img_raptor, radarzoom, ry, 0, sx, sy, 21, 22)
  love.graphics.draw(img_viper,  vx, vy, 0, sx, sy, 21, 28)
  love.graphics.draw(img_raider, mx, my, 0, sx, sy, 24, 22)
]]

  end -- for Radar[] Auswertung
end

function love.keypressed(key, unicode)
  if key == "+" then -- radar zoom in
    radarzoom = radarzoom * 2
    if radarzoom > 100 then
      radarzoom = 100
    end
  end
  if key == "-" then -- radar zoom out
    radarzoom = radarzoom / 2
    if radarzoom < 0.1 then
      radarzoom = 0.1
    end
  end

end

function string:split(delimiter) 
  local result = { } 
  local from  = 1 
  local delim_from, delim_to = string.find( self, delimiter, from  ) 
  while delim_from do 
    table.insert( result, string.sub( self, from , delim_from-1 ) ) 
    from  = delim_to + 1 
    delim_from, delim_to = string.find( self, delimiter, from  ) 
  end 
  table.insert( result, string.sub( self, from  ) ) 
  return result 
end 
