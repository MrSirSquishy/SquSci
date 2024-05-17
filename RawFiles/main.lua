local love = require("love")
local loads = require("load")
local toolss = require("tools")
local gui = require("gui")
local energy = require("energy")
local homepage = require("homepage")
local FileManipulator = require("FileManipulator")




colormultipler = 1 -- 1 or 255 scaling
movetime = true
dtfactor = 1/120


timespeed = 1
local tool = "hand"

--KEYBOARD STUFF 
local input = ""
local entered = ""
local fs = false
--KeyReleased
function love.keyreleased(key)
if key == "g" then
  fs = not fs
  love.window.setMode(500, 400, {fullscreen = fs})
end
if key == "space" then
  movetime = not movetime
end
end

--KeyPressed
function love.keypressed(key)

if key == "escape" then
  currentPage = "Main Page"
end


local ignoreInput = false
if key == "backspace" then --TYPING BACKSPACE
  input = input:sub(1, -2)
  for i, v in ipairs(textBoxes) do
    textBoxes[i]:textInput(-1)
  end
end
for i, v in ipairs(textBoxes) do
  if v.selected then ignoreInput = true end
end

if not ignoreInput then  
  if key == "=" then --ZOOM IN
    camx = camx - (love.graphics.getWidth()/camscale-love.graphics.getWidth()/camscale/1.2)/2
    camy = camy - (love.graphics.getHeight()/camscale-love.graphics.getHeight()/camscale/1.2)/2

    camscale = camscale * 1.2
  elseif key == "-" then --ZOOM OUT

    camx = camx + (love.graphics.getWidth()/camscale-love.graphics.getWidth()/camscale/1.2)/2
    camy = camy + (love.graphics.getHeight()/camscale-love.graphics.getHeight()/camscale/1.2)/2
    camscale = camscale/1.2

  elseif key == "return" then --TYPING ENTER
    entered = input
    input = ""
  elseif key == "0" then
    timespeed = timespeed * 1.5
  elseif key == "9" then
    timespeed = timespeed / 1.5

  elseif key == "s" then
    saveAttributes(GlobalAttributeMemory)
  elseif key == "l" then
    loadAttributes(GlobalAttributeMemory)
  end
end
end

--Text Input
function love.textinput(t)
  input = input .. t
  for i, v in ipairs(textBoxes) do
    textBoxes[i]:textInput(t)
  end
end

--MouseWheel Scrolling
scrollvalue = 0
function love.wheelmoved(x, y)
if y > 0 then
  camx = camx - (love.graphics.getWidth()/camscale-love.graphics.getWidth()/camscale/1.2)/2
  camy = camy - (love.graphics.getHeight()/camscale-love.graphics.getHeight()/camscale/1.2)/2
  camscale = camscale * 1.2
elseif y < 0 then
  camx = camx + (love.graphics.getWidth()/camscale-love.graphics.getWidth()/camscale/1.2)/2
  camy = camy + (love.graphics.getHeight()/camscale-love.graphics.getHeight()/camscale/1.2)/2
  camscale = camscale/1.2
end
end

--Mouse
function love.mousepressed(x, y)
for i, v in ipairs(textBoxes) do
  textBoxes[i]:mousePress(x, y)
end
end


mouseup = false





--local frame = 1
--local dtl = {}
--MAIN UPDATE FUNCTION STUFF --------------------------------
-------------------------------------------------------------

local wasleftclick = false
local wasrightclick = false
local oldmousepos = {}
local wasmousedown = false
oldmousepos.x = 0
oldmousepos.y = 0
---------------------
local gt = 0
local lt = 100

function love.update(dt)

if not love.mouse.isDown(1) and wasmousedown then
    mouseup = true
  else
    mouseup = false
  end
wasmousedown = love.mouse.isDown(1)

cursor = "arrow"

--[[smoother dt
dtl[frame] = dt
frame = frame + 1
if frame > 8 then frame = 1 end
local avg = 0
for i, v in ipairs(dtl) do
  avg = avg + v
end
  ]]


local repeats = math.floor(dt/dtfactor)
dt = dtfactor



if currentPage == "PHYSICS" then
  for _ = 0, repeats do
      --MOUSE STUFF
    pointerOverlapDetect()

    mousex = love.mouse.getX()/camscale - camx
    mousey = love.mouse.getY()/camscale - camy
    leftclick = love.mouse.isDown(1)
    rightclick = love.mouse.isDown(2)

    pointer.b:setX(mousex)
    pointer.b:setY(mousey)

    mousevelx = (mousex - oldmousepos.x)/ppm/dt*12
    mousevely = (mousey - oldmousepos.y)/ppm/dt*12

    local inGUI = updateGUI(dt)
    for i, v in ipairs(textBoxes) do
      if textBoxes[i]:update(dt) then
        inGUI = true
      end
    end

    tools(tool, leftclick, rightclick, wasleftclick, wasrightclick, mousex, mousey, inGUI)



    --KEYS DOWN
    if love.keyboard.isDown("right") then
      camx = camx - 10/camscale
    elseif love.keyboard.isDown("left") then
      camx = camx + 10/camscale
      --ball1.b:applyLinearImpulse(-200,0)
    end
    if love.keyboard.isDown("up") then
      camy = camy + 10/camscale
    elseif love.keyboard.isDown("down") then
      camy = camy - 10/camscale
    end



    --WORLD MOVING WITH TIME
    if movetime then
      if timespeed > 1 then
        for _ = 1, timespeed do
            world:update(dt)

            for _, v in ipairs(objects) do 
              v:update(dt)
            end
        end
      else
          world:update(dt*timespeed)

          for i, v in ipairs(objects) do 
            v:update(dt*timespeed)
          end
      end

    else
      world:update(dt*.000000001)
        for i, v in ipairs(objects) do 
          v:update(dt*.000000001)
        end
    end


    updateEnergy(dt)


    love.mouse.setCursor(love.mouse.getSystemCursor(cursor))


    if string.len(text) > 400 then    -- cleanup when 'text' gets too long
        text = "" 
    end

    wasrightclick = rightclick
    wasleftclick = leftclick
    oldmousepos.x = mousex
    oldmousepos.y = mousey

    end
  end

  for _, v in pairs(pages) do
    v:update(dt)
  end

end


---------------------








--DRAWING
function love.draw()


  if currentPage == "PHYSICS" then
    love.graphics.setBackgroundColor(
      .074*colormultiplier, .02*colormultiplier, .25*colormultiplier
    )

    --scaling push
    love.graphics.push()
  love.graphics.setColor(1*colormultipler,1*colormultipler,1*colormultipler,1*colormultipler)
  --love.graphics.circle("fill", mousex, mousey, 4, 20)

    --CAMERA MOVEMENT AND SCALE
    love.graphics.scale(camscale)
    love.graphics.translate(camx, camy)
    --drag movement

    love.graphics.circle("fill", pointer.b:getX(), pointer.b:getY(), pointer.s:getRadius(), 20)




    --DRAWS ALL OBJECTS
    for i, v in ipairs(objects) do
      objects[i]:draw()
    end
    for i, v in ipairs(objects) do
      objects[i]:drawOverlay()
    end



    --DRAW TOOLS
    drawTools()



    love.graphics.pop()

    drawEnergy()
    drawGUI()
  end


  for _, v in pairs(pages) do
    v:draw()
  end



end





--COLLISIONS

function beginContact(a, b, coll)
--[[
if b:getUserData() == "Mouse" then
  pointer.objmemory = a
elseif a:getUserData() == "Mouse" then
  pointer.objmemory = b
end
]]
x,y = coll:getNormal()
text = text.."\n"..a:getUserData().." colliding with "..b:getUserData().." with a vector normal of: "..x..", "..y
end




function endContact(a, b, coll)
--[[
if pointer.objmemory then
  if (b:getUserData() == "Mouse" or a:getUserData() == "Mouse") and (b:getUserData() == pointer.objmemory:getUserData() or a:getUserData() == pointer.objmemory:getUserData()) then
    pointer.objmemory = nil
  end
end
]]
persisting = 0    -- reset since they're no longer touching
text = text.."\n"..a:getUserData().." uncolliding with "..b:getUserData()
end


function preSolve(a, b, coll)
if persisting == 0 then    -- only say when they first start touching
    text = text.."\n"..a:getUserData().." touching "..b:getUserData()
elseif persisting < 20 then    -- then just start counting
    text = text.." "..persisting
end
persisting = persisting + 1    -- keep track of how many updates they've been touching for

end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
-- we won't do anything with this function
end
