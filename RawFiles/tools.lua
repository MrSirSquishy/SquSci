local gui = require("gui")

local mouseSavePos = {0, 0}
local rectx = 0
local recty = 0
local rectw = 0
local recth = 0
local objectnumber = 0
mouseGrabMemory = {0, 0}

local xpos = 0
local ypos = 0 
local width = 1
local height = 1
local radius = 1
local mass = 1
local friction = 0
local restitution = 1
local nameIndex = 0
local fixed = false
local colorIndex = 1
local colors = {
{1, 1, 1}, --white
{0.5, 0.5, 0.5}, --gray
{0, 0, 0}, --black
{1, 0, 0}, --red
{1, .5, 0}, --orange
{1, 1, 0}, -- yellow
{0, 1, 0}, --green
{0, 1, 1}, --cyan
{.5, 0, 1}, --purple
{1, 0, 1}, --pink
}


local function xPosition(val)
if val then
xpos = val
end
return math.floor(xpos*10000+0.5)/10000
end
local function yPosition(val)
if val then
ypos = val
end
return math.floor((ypos)*10000+0.5)/10000
end


local function rectWidth(val, incr)
incr = incr or 1
if val then
if val == 0 then
  width = 1
else
  width = math.abs(val)
end

end
return math.floor(width*1000 + .5)/1000
end
local function rectHeight(val, incr)
incr = incr or 1
if val then
if val == 0 then
  height = 1
else
  height = math.abs(val)
end

end
return math.floor(height*1000 + .5)/1000
end
local function setRadius(val, incr)
incr = incr or 1
if val then
if val == 0 then
  radius = 1
else
  radius = math.abs(val)
end

end
return math.floor(radius*1000 + .5)/1000
end

local function setMass(val)
if val then
mass = val
end
return math.floor(mass*10000+0.5)/10000
end
local function setFriction(val)
if val then
friction = val
end
return math.floor(friction*10000+0.5)/10000
end
local function setRestitution(val)
if val then
restitution = val
end
return math.floor(restitution*10000+0.5)/10000
end

function toggleDynamic(toggle)
if toggle then
fixed = not fixed
end
return fixed
end



local function setColor(val) 
if val then
colorIndex = val
end

return colors, colorIndex
end


local function finish()
local dynamic = "dynamic"
nameIndex = nameIndex + 1
if fixed then
friction = 1
restitution = 0
dynamic = "static"
end
if CreateRectGUI.enabled then
CreateRectGUI.enabled = false
table.insert(objects, rect.new("USEROBJECT"..nameIndex, 
  (xpos)*ppm, linepos-(ypos)*ppm, 
   width, height, dynamic, mass, restitution, friction, "fill", colors[colorIndex]))

elseif CreateTriGUI.enabled then

CreateTriGUI.enabled = false
table.insert(objects, tri.new("USEROBJECT"..nameIndex, 
    (xpos)*ppm, linepos-(ypos)*ppm, 
     width, height, dynamic, mass, restitution, friction, "fill", colors[colorIndex]))

elseif CreateCircleGUI.enabled then
CreateCircleGUI.enabled = false
table.insert(objects, circle.new("USEROBJECT" ..nameIndex, 
    xpos*ppm, linepos-ypos*ppm, 
    radius, dynamic, "fill", mass, restitution, friction, colors[colorIndex]))

end
end


CreateRectGUI = GUI:new(
{
guiElement:new(xPosition, 32, nil, "textBox", 
{"X position (m)"}),
guiElement:new(yPosition, 32, nil, "textBox", 
{"Y position (m)"}),
guiElement:new(rectWidth, 50, nil, "slider",
{"Width (m)", width, 0.1, 10, nil, nil, .1}),
guiElement:new(rectHeight, 50, nil, "slider",
{"Height (m)", height, 0.1, 10, nil, nil, .1}),
guiElement:new(setMass, 32, nil, "textBox", 
{"Mass"}),
guiElement:new(setFriction, 32, nil, "textBox", 
{"Coefficient of Friction"}),
guiElement:new(setRestitution, 32, nil, "textBox", 
{"Coefficient of Restitution"}),
guiElement:new(toggleDynamic, 25, nil, "toggle", 
{"Fixed in Place"}),
guiElement:new(setColor, 25, nil, "color", 
  {"Color"}),
guiElement:new(finish, 25, nil, "button",
{"Finish"})
},
0, 0, 200, 10,
{1*colormultiplier,1*colormultiplier, 1*colormultiplier}
)
table.insert(GUIS, CreateRectGUI)
CreateRectGUI.enabled = false


CreateTriGUI = GUI:new(
{
guiElement:new(xPosition, 32, nil, "textBox", 
{"X position (m)"}),
guiElement:new(yPosition, 32, nil, "textBox", 
{"Y position (m)"}),
guiElement:new(rectWidth, 50, nil, "slider",
{"Width (m)", width, 0.1, 10, nil, nil, .1}),
guiElement:new(rectHeight, 50, nil, "slider",
{"Height (m)", height, 0.1, 10, nil, nil, .1}),
guiElement:new(setMass, 32, nil, "textBox", 
{"Mass "}),
guiElement:new(setFriction, 32, nil, "textBox", 
{"Coefficient of Friction"}),
guiElement:new(setRestitution, 32, nil, "textBox", 
{"Coefficient of Restitution"}),
guiElement:new(toggleDynamic, 25, nil, "toggle", 
{"Fixed in Place"}),
guiElement:new(setColor, 25, nil, "color", 
{"Color"}),
guiElement:new(finish, 25, nil, "button",
{"Finish"})
},
0, 0, 200, 10,
{1*colormultiplier,1*colormultiplier, 1*colormultiplier}
)
table.insert(GUIS, CreateTriGUI)
CreateTriGUI.enabled = false

CreateCircleGUI = GUI:new(
{
guiElement:new(xPosition, 32, nil, "textBox", 
{"X position (m)"}),
guiElement:new(yPosition, 32, nil, "textBox", 
{"Y position (m)"}),
guiElement:new(setRadius, 50, nil, "slider",
{"Radius (m)", width, 0.1, 4, nil, nil, .1}),
guiElement:new(setMass, 32, nil, "textBox", 
{"Mass"}),
guiElement:new(setFriction, 32, nil, "textBox", 
{"Coefficient of Friction"}),
guiElement:new(setRestitution, 32, nil, "textBox", 
{"Coefficient of Restitution"}),
guiElement:new(toggleDynamic, 25, nil, "toggle", 
{"Fixed in Place"}),
guiElement:new(setColor, 25, nil, "color", 
{"Color"}),
guiElement:new(finish, 25, nil, "button",
{"Finish"})
},
0, 0, 200, 10,
{1*colormultiplier,1*colormultiplier, 1*colormultiplier}
)
table.insert(GUIS, CreateCircleGUI)
CreateCircleGUI.enabled = false



local function openRect() 
rClickGUI.enabled = false
CreateRectGUI.enabled = true
CreateRectGUI.x = rClickGUI.x + 25
CreateRectGUI.y = 25
xpos = (rClickGUI.x/camscale-camx-50)/ppm
ypos = (rClickGUI.y+camy)/ppm
end

local function openTri() 
rClickGUI.enabled = false
CreateTriGUI.enabled = true
CreateTriGUI.x = rClickGUI.x + 25
CreateTriGUI.y = 25
xpos = (rClickGUI.x/camscale-camx-50)/ppm
ypos = (rClickGUI.y+camy)/ppm
end

local function openCircle()
rClickGUI.enabled = false
CreateCircleGUI.enabled = true
CreateCircleGUI.x = rClickGUI.x + 25
CreateCircleGUI.y = 25
xpos = (rClickGUI.x/camscale-camx-50)/ppm
ypos = (rClickGUI.y+camy)/ppm
end

rClickGUI = GUI:new(
{
guiElement:new(openRect, 25, nil, "button",
{"Rectangle"}),
guiElement:new(openCircle, 25, nil, "button",
{"Circle"}),
guiElement:new(openTri, 25, nil, "button",
{"Right Triangle"})
},
0, 0, 150, 10, 
{1*colormultiplier,1*colormultiplier, 1*colormultiplier}
)
table.insert(GUIS, rClickGUI)
rClickGUI.enabled = false
--DIIFERENT MOUSE TOOLS




--MAIN UPDATE FUNCTION
---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------
function tools(tool, l, r, wl, wr, x, y, inGUI)
--mouse positions relative to screen
local mousex = love.mouse.getX()
local mousey = love.mouse.getY()
print(CreateCircleGUI.enabled)
if not inGUI then

if r then
rClickGUI.enabled = false
CreateRectGUI.enabled = false
for i, v in ipairs(objects) do 
  v.GUI.enabled = false
end

if pointer.objmemory then --object setting gui
  pointer.objmemory.GUI.enabled = true

else --right click gui
  rClickGUI.enabled = true
  rClickGUI.x = mousex
  rClickGUI.y = mousey
end
end

if mouseup then
      rClickGUI.enabled = false
      CreateRectGUI.enabled = false
      CreateCircleGUI.enabled = false
      CreateTriGUI.enabled = false
end


if l then --left held down
rClickGUI.enabled = false
CreateRectGUI.enabled = false
for i, v in ipairs(objects) do 
  v.GUI.enabled = false
end
--HAND OBJECT GRABBING TOOL
if tool == "hand" and pointer.objmemory ~= nil then --when touching a dynamic object

  --Checks what type of shape it is
  local shapetype = "circle"
  if pointer.objmemory.s:getType() == "polygon" then    
    points = {pointer.objmemory.s:getPoints()}
    if not points[7] then
        shapetype = "tri"
    else
        shapetype = "rect"
    end    
  end

  --tri requires extra movement, finds the center of the tri and adjusts accordingly.
  if shapetype == "tri" then 
    pointer.objmemory.b:setX(
      x - (points[1]+points[3]+points[5])/3
    )
    pointer.objmemory.b:setY(
      y - (points[2]+points[4]+points[6])/3
    )
  else --other objects work normally
    pointer.objmemory.b:setX(x)
    pointer.objmemory.b:setY(y)
  end

  --removes all attributes of grabbed object
  pointer.objmemory.b:setLinearVelocity(0,0)
  pointer.objmemory.b:setAngle(0
  )
  pointer.objmemory.b:setAngularVelocity(0)


elseif tool == "rect" then

  if mouseSavePos[1] == 0 and mouseSavePos[2] == 0 then
    mouseSavePos = {x, y}
  end
  rectx = mouseSavePos[1]
  recty = mouseSavePos[2]
  rectw = x - rectx
  recth = y - recty


else --DRAG MOVEMENT

  if mouseGrabMemory[1] == 0 and mouseGrabMemory[2] == 0 then
    mouseGrabMemory = {x, y}
  end

  camx = camx - mouseGrabMemory[1] + x
  camy = camy - mouseGrabMemory[2] + y

end
-- AFTER MOUSE CLICK
elseif wl and not inGUI then

if tool == "rect" and mouseSavePos ~= {0, 0} and rectw ~= 0 and recth ~= 0 then
  --Creates Rectangle Object on 
  if rectw < 0 then
    rectx = rectx + rectw
    rectw = -rectw
  end
  if recth < 0 then
    recty = recty + recth
    recth = -recth
  end
  table.insert(objects, 
    rect.new(
      "rectangle"..objectnumber, rectx+rectw/2, recty+recth/2, rectw/ppm, recth/ppm, "dynamic", 1, 0, "fill", {.5,.25,1,1}
    )
  )    

  objectnumber = objectnumber + 1

elseif pointer.objmemory ~= nil then
  pointer.objmemory.b:setLinearVelocity(mousevelx, mousevely)

end

mouseGrabMemory = {0, 0}
mouseSavePos = {0, 0}
rectx = 0
recty = 0
recth = 0
rectw = 0

end
end


end


--drawing function for any tool-related thing
function drawTools()
love.graphics.setColor(colors[colorIndex])
love.graphics.rectangle("fill", rectx, recty, rectw, recth)


if CreateRectGUI.enabled then
love.graphics.rectangle("fill", (xpos-width/2)*ppm, linepos-(ypos+height/2)*ppm, width*ppm, height*ppm)
elseif CreateTriGUI.enabled then
local x1 = (xpos-width/2)*ppm
local x2 = (xpos+width/2)*ppm
local y1 = linepos-(ypos+height/2)*ppm
local y2 = linepos-(ypos-height/2)*ppm
love.graphics.polygon("fill", x1, y2, x2, y2, x2, y1)
elseif CreateCircleGUI.enabled then
love.graphics.circle("fill", xpos*ppm, linepos-(ypos)*ppm, radius*ppm)
end
end