local Object = require("Object")
love.filesystem.write("empty.txt", "")
ppm = 50
local gravity = 9.8
FluidDensity = 0
world = love.physics.newWorld(0, gravity*ppm, true)
textBoxes = {}
ignoreInput = false
camscale = 1
camx = 0
camy = 0
objects = {}
cursor = "arrow"

--TEXT BOX CLASS
textBox = {}
textBox.__index = textBox
function textBox.new(x, y, width, isNumber, charLimit)
local self = setmetatable({}, textBox)
self.x = x or 0
self.y = y or 0
self.width = width or 100
self.height = love.graphics.getFont():getHeight()
self.charLimit = charLimit or 16
self.hovered = false
self.selected = false
self.input = ""
self.isNumber = true
if isNumber == false then
  self.isNumber = false
end

self.num = 0
self.timer = 0

function self:mousePress()

if self.hovered then
mousedown = "TextBox"
self.selected = true
else
self.selected = false
end
end

function self:textInput(t) 
if self.isNumber and t ~= -1 then 
t = t:match("[%-%d%.]")
end

if self.selected then
if t == -1 then
  self.input = self.input:sub(1, -2)
elseif #self.input <= self.charLimit and t then
  self.input = self.input .. t
end

end
self.num = tonumber(self.input)
end

function self:update(dt)
local x = love.mouse:getX()
local y = love.mouse:getY()

self.hovered = CheckCollision(
self.x, self.y, self.width, self.height,
x-2.5, y-2.5, 5, 5
)

return self.hovered or self.selected
end

function self:draw()
self.timer = self.timer + 1
if self.timer > 60 then self.timer = 0 end
local cursor = ""
if self.timer > 29 and self.selected then
cursor = "|"
end

love.graphics.setColor(
1*colormultipler,1*colormultipler,1*colormultipler)

if self.selected then
  love.graphics.setColor(1*colormultipler,1*colormultipler,0)
elseif self.hovered then 
  love.graphics.setColor(
    .5*colormultipler,.5*colormultipler,.5*colormultipler
  )
end

love.graphics.rectangle("line", 
self.x, self.y, self.width, self.height
)
love.graphics.setColor(         
1*colormultipler,1*colormultipler,1*colormultipler)
love.graphics.print(self.input..cursor, self.x, self.y)	


end

function self.setNum(n)
self.num = n or 0
self.input = tostring(n)
end

return self
end




-- Collision detection function;
-- Returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
return x1 < x2+w2 and
   x2 < x1+w1 and
   y1 < y2+h2 and
   y2 < y1+h1
end

function rotatePoint(point, ang)
local c = math.cos(ang)
local s = math.sin(ang)
return {point[1]*c - point[2]*s, point[1]*s + point[2]*c}
end

function clamp(min, val, max)
return math.max(math.min(max, val), min)
end

function love.load()
--Variables
--pixels per meter


--Store the new world in a variable such as "world"
--Gravity is being set to 0 in the x direction and 200 in the y direction.
world:setCallbacks(beginContact, endContact, preSolve, postSolve)
text       = ""   
persisting = 0    


--Mouse Pointer
pointer = {}
pointer.b = love.physics.newBody(world, love.mouse.getX(), love.mouse.getY(), "static")
pointer.s = love.physics.newCircleShape(5)
pointer.f = love.physics.newFixture(pointer.b, pointer.s)
pointer.f:setUserData("Mouse")
pointer.f:setSensor(true)
pointer.objmemory = nil

function pointerOverlapDetect()
local x = pointer.b:getX()
local y = pointer.b:getY()
local r = pointer.s:getRadius()
local collision = nil


for i, v in ipairs(objects) do

  local collide = false
  if v.type == "rect" then
    collide = CheckCollision(
      x-r, y-r, r*2, r*2,
      v.b:getX()-v.w/2, v.b:getY()-v.h/2, v.w, v.h
    )
  elseif v.type == "circle" then
    collide = math.sqrt(
        (x-v.b:getX())^2 + (y-v.b:getY())^2
      ) <= v.s:getRadius()

  elseif v.type == "tri" then
    points = {v.b:getWorldPoints(v.s:getPoints())}
    local ax = points[1] - x
    local ay = points[2] - y
    local bx = points[3] - x
    local by = points[4] - y
    local cx = points[5] - x
    local cy = points[6] - y
    local sab = ax*by - ay*bx < 0
    if sab == (bx*cy - by*cx < 0) then
      collide = sab == (cx*ay - cy*ax < 0)
    end
  end
  if collide then
    collision = v
  end
end
if not love.mouse.isDown(1) then
  pointer.objmemory = collision
end
end


--tri.f:setRestitution(0.2)
--tri.b:setMass(10)
font = love.graphics.newImageFont("examplefont.png",
" abcdefghijklmnopqrstuvwxyz" ..
"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
"123456789.,!?-+/():;%&`'*#=[]\"")
--love.graphics.setFont(font)






--TRIANGLE OBJET
tri = {}
tri__index = tri
function tri.new(name, xpos, ypos, width, height, bodytype, mass, restitution, friction, filltype, color)
self = object.new(name, xpos, ypos, bodytype, mass, restitution, friction, color)
self.type = "tri"
self.w = width*ppm or ppm
self.h = height*ppm or ppm
self.fill = filltype or "fill"
self.s = love.physics.newPolygonShape(
self.b:getX(), self.b:getY(), 
self.b:getX() + self.w, self.b:getY() - self.h, 
self.b:getX() + self.w, self.b:getY()
)
self.f = love.physics.newFixture(self.b, self.s)
self.f:setUserData(self.name)
self.f:setRestitution(self.restitution)
self.f:setFriction(self.friction)
self.b:setFixedRotation(true)
--self.b:setMass(self.mass)
--self.inertia = self.mass*(self.w^2+self.h^2)/36 * ppm^2

--local x,y,mass,inertia = self.b:getMassData()

--self.b:setMassData(x,y,mass,self.inertia)
    
--print(self.b:getInertia(), self.inertia)
--self.b:setInertia(self.inertia)


function self:draw()
love.graphics.setColor(self.color)
love.graphics.polygon(self.fill, self.b:getWorldPoints(self.s:getPoints()))
end

return self
end

--RECTANGLE OBJECT
rect = {}
rect.__index = rect
function rect.new(name, xpos, ypos, width, height, bodytype, mass, restitution, friction, filltype, color)
self = object.new(name, xpos, ypos, bodytype, mass, restitution, friction, color)
self.type = "rect"
self.w = width*ppm or ppm
self.h = height*ppm or ppm
self.fill = filltype or "fill"
self.s = love.physics.newRectangleShape(self.w, self.h)
self.f = love.physics.newFixture(self.b, self.s)
self.f:setUserData(self.name)
self.f:setRestitution(self.restitution)
self.f:setFriction(self.friction)
self.inertia = self.mass*(self.w^2+self.h^2)/12
self.b:setInertia(self.inertia)


function self:draw()
love.graphics.setColor(self.color)
love.graphics.polygon(self.fill, self.b:getWorldPoints(self.s:getPoints()))
end



return self
end



--CIRCLE OBJECT
circle = {}
circle.__index = circle
function circle.new(name, xpos, ypos, radius, bodytype, filltype, mass, restitution, friction, color)
self = object.new(name, xpos, ypos, bodytype, mass, restitution, friction, color)
self.type = "circle"
self.radius = radius*ppm or ppm
self.sides = 20
self.fill = filltype or "fill"
self.s = love.physics.newCircleShape(self.radius)
self.f = love.physics.newFixture(self.b, self.s)
self.f:setUserData(self.name)
self.f:setRestitution(self.restitution)
self.f:setFriction(self.friction)
self.inertia = 0
self.inertiaType = "cylinder"

self.inertiaTypeNum = 1




table.insert(self.GUI.elements, 
guiElement:new(nil, 25, nil, "dropdown", {{
          guiElement:new(self.setInertiaType, 90, nil, "selection", {{
                "Cylinder",
                "Hoop",
                "Sphere",
                "Hollow Sphere"
          }})
}, "Inertia Type", false})
)

function self:updateInertia()
  if self.inertiaType == "hollow sphere" then
    self.inertia = 2/3*self.mass*(self.radius^2)/2
  elseif self.inertiaType == "sphere" then
    self.inertia = 2/5*self.mass*(self.radius^2)
  elseif self.inertiaType == "hoop" then
    self.inertia = self.mass*(self.radius^2)
  else
    self.inertia = self.mass*(self.radius^2)/2
  end
  self.b:setInertia(self.inertia)
end

self:updateInertia()


function self:draw()
  local c = self.color
love.graphics.setColor(c)

  if self.inertiaType == "sphere" or 
    self.inertiaType == "hollow sphere" then

    local r = self.radius
    local lightx = 0
    local lighty = 0



    local ang = 
    math.atan((lighty-linepos-self.ypos)/(lightx-self.xpos))

    if self.xpos > lightx then
      ang = ang + math.pi
    end


    --draw light direction
    --love.graphics.line(self.xpos, self.ypos,self.xpos+math.cos(ang)*300, self.ypos+math.sin(ang)*300)

    love.graphics.setColor(c[1]/1.5, c[2]/1.5, c[3]/1.5)
    love.graphics.circle("fill", self.b:getX(), self.b:getY(), self.s:getRadius(), 20)

    local r2 = r/9
    love.graphics.setColor(c[1]/1.25, c[2]/1.25, c[3]/1.25)
    love.graphics.circle("fill", 
      self.b:getX()+r2*math.cos(ang), 
      self.b:getY()+r2*math.sin(ang), 
      self.s:getRadius()-r2*1.5, 20)


    love.graphics.setColor(c)
    love.graphics.circle("fill", 
      self.b:getX()+(r/3.5)*math.cos(ang), 
      self.b:getY()+(r/3.5)*math.sin(ang), 
      self.s:getRadius()-r*0.55, 20)



  elseif self.inertiaType == "hoop" then
    love.graphics.setLineWidth(4)
    love.graphics.circle("line", self.b:getX(), self.b:getY(), self.s:getRadius(), 20)
    love.graphics.setLineWidth(1)
  else
    love.graphics.circle("fill", self.b:getX(), self.b:getY(), self.s:getRadius(), 20)
  end


end

return self
end


--TEXT BOXES OBJECT



--table.insert(objects, rect.new("floor", -100000, 650, 1000000, 10, "static", 1, 0, 0.5, "fill", {.5,.5,.5,1}))
--table.insert(objects, rect.new("rect1", 300, 100, 1, 1, "dynamic", 1, 0, "line", {1,0,1,1}))
--table.insert(objects, rect.new("rect2", 300, 100, 1, 1, "dynamic", 1, .5, 0.5, "fill", {1,1,0,1}))
--table.insert(objects, rect.new("rect3", 400, 100, 1, 1, "dynamic", 1, .5, 0.5, "fill", {1,1,0,1}))
--table.insert(objects, circle.new("ball1", 200, 0, 1, "dynamic", "fill", 1, .8, 0.5, {0, 1, 1, 1}))
--objects[3].inertiaType = "cylinder"

--table.insert(objects, circle.new("ball5", 500, 0, 5, "dynamic", "fill", 1, .8, {0, 1, 1, 1}))

--table.insert(objects, circle.new("ball2", 300, 0, 1, "dynamic", "fill", 1, .8, {0, 1, 1, 1}))
--objects[4].inertiaType = "sphere"

--table.insert(objects, circle.new("ball3", 400, 0, 1, "dynamic", "fill", 1, .8, {0, 1, 1, 1}))
--objects[5].inertiaType = "hoop"
--table.insert(objects, circle.new("ball2", 400, 0, .5, "dynamic", "fill", 1, 1, {0, 1, 0, 1}))
--table.insert(objects, tri.new("tri1", 100, 100, 1, 1.5, "dynamic", 1, .5, "fill", {1,1,1,1}))
--table.insert(objects, tri.new("tri2", 200, 200, 5, 3, "dynamic", 1, .5, 0.5, "fill", {1,1,1,1}))

love.graphics.setBackgroundColor(0.11, 0.14, 0.33)
end



