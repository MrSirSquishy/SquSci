GravitationalConstant = 6.674 * math.pow(10, -11)
GravitationalForces = true

--OBJECT SUPERCLASS
object = {}
object.__index = object
function object.new(name, xpos, ypos, bodytype, mass, restitution, friction, color)
local color = color or {1, 1, 1, 1}
for i, v in pairs(color) do
color[i] = color[i] * colormultipler
end
local self = setmetatable({}, object)
self.showVel = false
self.showAcc = false
self.showAngle = false
self.showAngularVel = false
self.showAngularAcc = false
self.showHeight = false
self.showDistance = false
self.showPath = false
self.showVelVector = false
self.type = nil
self.name = name
self.mass = mass or 1
self.color = color or {1,1,1}
self.restitution = restitution or 0
self.bodytype = bodytype or "dynamic"
self.b = love.physics.newBody(world, xpos or 0, ypos or 0, self.bodytype)
self.b:setMass(self.mass)
self.dragCoefficient = 0.8 
self.dragReferenceArea = 1
--area in m^2



self.b:setSleepingAllowed(false)
self.centerx = 0
self.centery = 0
self.friction = friction or 0.5

self.KL = 0
self.KR = 0
self.UG = 0
self.E = 0

self.pathTrace = {}

self.gravpos = 0
self.xpos = 0
self.ypos = 0
self.oldxvel = 0
self.oldyvel = 0
self.xacc = 0
self.yacc = 0
self.angacc = 0
self.oldangvel = 0






--GUI ELEMENTS

---------------------------------------------------------------------
---------------------------------------------------------------------
function self.setFriction(friction, incr)
incr = incr or 0.0001
if friction then
  self.friction = (math.floor(friction / incr) * incr)
end
local y = self.friction
if self.f then self.f:setFriction(self.friction) end
return math.floor((y/incr)*10 + .5)/10*incr
end

function self.setRestitution(restitution, incr)
  incr = incr or 0.0001
  if restitution then

    self.restitution = (math.floor(restitution / incr) * incr)
  end
  local y = self.restitution
  if self.f then self.f:setRestitution(self.restitution) end
  return math.floor((y/incr)*10 + .5)/10*incr
end

function self.setMass(mass, incr)
  incr = incr or 0.0001
  if mass then
    self.mass = (math.floor(mass / incr) * incr)
    if self.type == "circle" then
      self:updateInertia()
    elseif self.type == "rect" then
      self.inertia = self.mass*(self.w^2+self.h^2)/12
      self.b:setInertia(self.inertia)
    elseif self.type == "tri" then
      --self.inertia = self.mass*(self.w^2+self.h^2)/36*80
      --self.b:setInertia(self.inertia)
    end
  end
  local y = self.mass
  self.b:setMass(self.mass)
  return math.floor((y/incr)*10 + .5)/10*incr
end

function self.toggleHeight(toggle)
if toggle then
self.showHeight = not self.showHeight
end

return self.showHeight
end

function self.toggleDistance(toggle)
if toggle then
  self.showDistance = not self.showDistance
end

return self.showDistance
end


function self.toggleInfo(toggle)
if toggle then
  self.InfoGUI.enabled = not self.InfoGUI.enabled
end
return self.InfoGUI.enabled
end

function self.togglePath(toggle)
if toggle then
    self.showPath = not self.showPath
end
return self.showPath
end

function self.toggleVel(toggle)
if toggle then
      self.showVel = not self.showVel
end
return self.showVel
end

function self.toggleVelVec(toggle)
if toggle then
      self.showVelVector = not self.showVelVector
end
return self.showVelVector
end

function self.toggleAcc(toggle)
if toggle then
      self.showAcc = not self.showAcc
end
return self.showAcc
end

function self.toggleAngle(toggle)
if toggle then
      self.showAngle = not self.showAngle
end
return self.showAngle
end

function self.toggleAngularVel(toggle)
if toggle then
      self.showAngularVel = not self.showAngularVel
end
return self.showAngularVel
end

function self.toggleAngularAcc(toggle)
if toggle then
      self.showAngularAcc = not self.showAngularAcc
end
return self.showAngularAcc
end

function self.energyDisplay()
local KL = math.floor(self.KL*100+0.5)/100
local KR = math.floor(self.KR*100+0.5)/100
local UG = math.floor(self.UG*100)/100
return 
"Total Energy: " ..
KL+KR+UG
.. " J \n\nTotal Kinetic: " .. 
KL+KR
.. " J \n  Linear: " ..
KL
.. " J \n  Rotational: " ..
KR
.. " J \n\nTotal potential: " .. 
UG
.. " J \n  Gravitational: " ..
UG
.. " J"
end


function self.xPosition(val)
if val then
self.b:setLinearVelocity(0, 0)
self.b:setX(val*ppm)
end
return math.floor(self.xpos/ppm*10000+0.5)/10000
end

function self.yPosition(val)

if val then
self.b:setLinearVelocity(0, 0)
self.b:setY(linepos - val*ppm)
end
return math.floor(((linepos - self.ypos)/ppm)*10000+0.5)/10000
end

function self.xVel(val)
local xvel, yvel = self.b:getLinearVelocity()
if val then
self.b:setLinearVelocity(val*ppm, yvel)
end

return math.floor(
((xvel)/ppm)*10000+0.5
)/10000
end

function self.angVel(val)
if val then
self.b:setAngularVelocity(val)
end

return math.floor(self.b:getAngularVelocity()*1000+0.5)/1000
end

function self.ang(val, incr)
incr = incr or 1
if val then
self.b:setAngle(-val*math.pi/180)
end
return math.floor((-self.b:getAngle()/math.pi*18000) + .5)/100
end

function self.yVel(val)
local xvel, yvel = self.b:getLinearVelocity()
if val then
self.b:setLinearVelocity(xvel, -val*ppm)
end

return -math.floor(
((yvel)/ppm)*10000+0.5
)/10000
end


function self.setInertiaType(num)

if num then

self.inertiaTypeNum = num
if self.inertiaTypeNum == 1 then
  self.inertiaType = "cylinder"
elseif self.inertiaTypeNum == 2 then
  self.inertiaType = "hoop"
elseif self.inertiaTypeNum == 3 then
  self.inertiaType = "sphere"
elseif self.inertiaTypeNum == 4 then
  self.inertiaType = "hollow sphere"
end

end


return self.inertiaTypeNum or 1
end

function self.delete()
self.GUI.enabled = false
self.InfoGUI.enabled = false
for i, v in ipairs(GUIS) do
  if v == self.GUI then
    table.remove(GUIS, i)
  elseif v == self.InfoGUI then
    table.remove(GUIS, i)
  end


end

for i, v in ipairs(objects) do
  if v.name == self.name then 
    v.b:destroy()
    table.remove(objects, i)

  end
end

end



--CREATE GUI
-------------------------------------------------------------------
-------------------------------------------------------------------
self.GUI = GUI:new(
{
guiElement:new(self.toggleInfo, 20, nil, "toggle", 
  {"Display Energy Info"}),
guiElement:new(nil, 25, nil, "dropdown", {{
      guiElement:new(self.setMass, 50, nil, "slider",
        {"Mass", self.mass, 0.01, 100, nil, nil, .01}),
      guiElement:new(self.setFriction, 50, nil, "slider",
        {"Friction", self.friction, 0, 1, nil, nil, .01}),
      guiElement:new(self.setRestitution, 50, nil, "slider",
        {"Restitution", self.restitution, 0, 1, nil, nil, .01})
}, "static properties", false}),

guiElement:new(nil, 25, nil, "dropdown", {{
      guiElement:new(self.xPosition, 32, nil, "textBox", 
        {"X position (m)"}),
      guiElement:new(self.yPosition, 32, nil, "textBox", 
        {"Y position (m)"}),
      guiElement:new(self.xVel, 32, nil, "textBox", 
        {"X Velocity (m/s)"}),
      guiElement:new(self.yVel, 32, nil, "textBox", 
        {"Y Velocity (m/s)"}),
      guiElement:new(self.ang, 50, nil, "slider",
        {"Angle (deg)", 0, 0, 360, nil, nil, .1}),
      guiElement:new(self.angVel, 32, nil, "textBox", 
        {"Angular Velocity (rad/s)"})
}, "live properties", false}),


guiElement:new(nil, 25, nil, "dropdown", {{
      guiElement:new(self.togglePath, 20, nil, "toggle", 
        {"Trace Path "}),
        guiElement:new(self.toggleHeight, 20, nil, "toggle", 
          {"Display Height"}),
        guiElement:new(self.toggleDistance, 20, nil, "toggle", 
          {"Display Distance"})
}, "position", false}),

guiElement:new(nil, 25, nil, "dropdown", {{
      guiElement:new(self.toggleVel, 20, nil, "toggle", 
        {"Display Velocity"}),
      guiElement:new(self.toggleVelVec, 20, nil, "toggle", 
      {"Display Velocity Vec"}),
      guiElement:new(self.toggleAcc, 20, nil, "toggle", 
        {"Display Acceleration"}),
      guiElement:new(self.toggleAngle, 20, nil, "toggle", 
        {"Display Angle"}),
      guiElement:new(self.toggleAngularVel, 20, nil, "toggle", 
        {"Display Angular Vel"}),
      guiElement:new(self.toggleAngularAcc, 20, nil, "toggle", 
        {"Display Angular Acc"})
}, "vectors/angles", false}),
  guiElement:new(self.delete, 25, nil, "button",
    {"Delete"})

},
0, 0, 150, 5, 
nil
)
self.GUI.enabled = false


self.InfoGUI = GUI:new(
{
  guiElement:new(self.energyDisplay, 120, nil, "display", 
    {"Total Kinetic: ", " J"})
},
0, 0, 150, 10,
{1*colormultiplier,1*colormultiplier, 1*colormultiplier}
)
self.InfoGUI.enabled = false


table.insert(GUIS, self.GUI)
table.insert(GUIS, self.InfoGUI)










--UPDATE FUNCTION
-------------------------------------------------------------------
-------------------------------------------------------------------
function self:update(dt)
self.b:setMass(self.mass)



if self.type == "tri" then
local points = {self.b:getWorldPoints(self.s:getPoints())}
self.xpos = (points[1]+points[3]+points[5])/3
self.ypos = (points[2]+points[4]+points[6])/3
else
self.xpos = self.b:getX()
self.ypos = self.b:getY()
end
  --[[
  if self.type == "circle" then
    camx = -self.b:getX() + love.graphics.getWidth()/2
    camy = -self.b:getY() + love.graphics.getHeight()/2
  end]] --lock in camera

self.gravpos = (linepos - self.ypos)/ppm

--GUI updates
self.GUI.x = (self.xpos + camx)*camscale
self.GUI.y = (self.ypos + camy)*camscale

self.InfoGUI.x = (self.xpos + camx)*camscale
self.InfoGUI.y = (self.ypos + camy)*camscale - 110

if self.bodytype == "dynamic" then
--Energy updates
local xvel, yvel = self.b:getLinearVelocity()
xvel = xvel/ppm
yvel = yvel/ppm
local angvel = self.b:getAngularVelocity()
local inertia = self.b:getInertia()/ppm^2
local gravx, gravy = world:getGravity() 


self.KL = 0.5 * self.mass*MassMultiplier * (xvel^2 + yvel^2)
self.KR = 0.5 * inertia*MassMultiplier * angvel^2
self.UG = self.mass*MassMultiplier * gravy/ppm * self.gravpos

self.E = self.KL + self.KR + self.UG


--prevents breakage when time frozen
if movetime then
  xvel, yvel = self.b:getLinearVelocity()
  self.xacc = (xvel-self.oldxvel)/dt
  self.yacc = (yvel-self.oldyvel)/dt
  if not self.oldangvel then self.oldangvel = 0 end
  self.angacc = (angvel-self.oldangvel)/dt
  self.oldangvel = angvel
  self.oldxvel = xvel
  self.oldyvel = yvel
end
  local _, gy = world:getGravity()


--Gravitational force simulation
if GravitationalForces and self.bodytype == "dynamic" then
for i, v in ipairs(objects) do
  if v.name ~= self.name then

    local xdistance = (v.xpos - self.xpos)/ppm
    local ydistance = (v.ypos - self.ypos)/ppm

    local distance = math.sqrt(xdistance^2 + ydistance^2)
   
    local force = 
GravitationalConstant * (v.mass * self.mass)/(distance)^2 * MassMultiplier
    local angle = math.atan2(ydistance, xdistance)

      local forcex = force*math.cos(angle) * ppm
      local forcey = force*math.sin(angle) * ppm


        if forcex < 10^100 and forcey < 10^100 then
        self.b:applyForce(forcex, forcey)
        end
  end

end
end


end

--Path tracing

if self.showPath then
table.insert(self.pathTrace, {self.xpos, self.ypos})
else
for i, _ in pairs(self.pathTrace) do 
  self.pathTrace[i] = nil 
end
end

--Air Resistance

if FluidDensity ~= 0 then


xvel, yvel = self.b:getLinearVelocity()
local AD = self.dragCoefficient*self.dragReferenceArea*ppm^2
local density = FluidDensity/ppm^3
local Acc = 0.5*density*(xvel^2+yvel^2)*AD/(self.mass*MassMultiplier)

--local xForce = 0.5*density*(xvel^2)*AD
--local yForce = 0.5*density*(yvel^2)*AD
self.b:setLinearDamping(Acc/ppm)

end

if self.name == "ball1" then
--print(#self.pathTrace)
--print(self.timer)
--print(self.E)

end
end







-- DRAW OVERLAY

-------------------------------------------------------------------
-------------------------------------------------------------------



--draws vectors n stuff
function self:drawOverlay(dt)

local x = self.b:getX()
local y = self.b:getY()
local xvel, yvel = self.b:getLinearVelocity()
local angacc = self.angacc
local xacc = self.xacc
local yacc = self.yacc
local angvel = self.b:getAngularVelocity()




--centers tri
if self.type == "tri" then
points = {self.b:getWorldPoints(self.s:getPoints())}
x = (points[1]+points[3]+points[5])/3
y = (points[2]+points[4]+points[6])/3
end

local radius = 0
if self.type == "circle" then
radius = self.s:getRadius()
elseif self.type == "tri" or self.type == "rect" then
radius = math.max(self.w, self.h)/2
end


if self.showVel then --VECLOTIY 

love.graphics.setColor(
  .12*colormultipler, .75*colormultipler, .27*colormultipler
)
--x velocity vector
love.graphics.rectangle("fill", 
  x, y-2.5, xvel/5, 5
)
local simplexvel = math.floor(xvel/ppm*100+.5)/100
local veldir = 0
if simplexvel < 0 then
  veldir = -1
elseif simplexvel > 0 then
  veldir = 1
end

love.graphics.polygon("fill",
  x+xvel/5, y+5, x+xvel/5, y-5, x+xvel/5 + 10*veldir, y
)
if veldir ~= 0 then
love.graphics.print(simplexvel.." m/s", x+xvel/5, y+5, 0, 1.25)
end

--y velocity vector
love.graphics.rectangle("fill", 
    x-2.5, y, 5, yvel/5
)
local simpleyvel = math.floor(yvel/ppm*100+.5)/100
veldir = 0
if math.floor(simpleyvel+.5) < 0 then
    veldir = -1
elseif math.floor(simpleyvel+.5) > 0 then
    veldir = 1
end
love.graphics.polygon("fill",
    x+5, y+yvel/5, x-5, y+yvel/5, x, y+yvel/5 + 10*veldir
)
if veldir ~= 0 then
  love.graphics.print(simpleyvel.." m/s", x+5, y+yvel/5, 0, 1.25)
end
x = x - 5
y = y - 5
end

if self.showAcc then --ACCELERATION
local xacclength = 0
local yacclength = 0
if xacc < 0 then
  xacclength = -math.sqrt(-xacc*8)
else
  xacclength = math.sqrt(xacc*8)
end

if yacc < 0 then
  yacclength = -math.sqrt(-yacc*8)
else
  yacclength = math.sqrt(yacc*8)
end

  love.graphics.setColor(
      .2*colormultipler, .68*colormultipler, .92*colormultipler
  )
--x acc vector

  love.graphics.rectangle("fill", 
      x, y-2.5, xacclength, 5
  )
  local simplexvel = math.floor(xacc/ppm*100+.5)/100
  local veldir = 0
  if simplexvel < 0 then
      veldir = -1
  elseif simplexvel > 0 then
      veldir = 1
  end

  love.graphics.polygon("fill",
      x+xacclength, y+5, x+xacclength, y-5, x+xacclength + 10*veldir, y
  )
  if veldir ~= 0 then
    love.graphics.print(simplexvel.." m/s²", x+xacclength, y+5, 0, 1.25)
  end

--y accel vector
    love.graphics.rectangle("fill", 
        x-2.5, y, 5, yacclength
    )
    local simpleyvel = math.floor(yacc/ppm*100+.5)/100
    veldir = 0
    if math.floor(simpleyvel+.5) < 0 then
        veldir = -1
    elseif math.floor(simpleyvel+.5) > 0 then
        veldir = 1
    end
    love.graphics.polygon("fill",
        x+5, y+yacclength, x-5, y+yacclength, x, y+yacclength + 10*veldir
    )
    if veldir ~= 0 then
      love.graphics.print(simpleyvel.." m/s²", x+5, y+yacclength, 0, 1.25)
    end
end




local radialoffset = 10
if self.showAngle then --ANGLE
  local ang = (((math.floor(self.b:getAngle()*100+.5)/100)+math.pi)%(math.pi*2)-math.pi)

  if self.type == "rect" or self.type == "tri" then
    ang = ang%(-math.pi/2)
  end

  love.graphics.setColor(
      1*colormultipler, 1*colormultipler, 1*colormultipler
  )

  local checkang = math.floor(ang/math.pi*180+.5) --if the angle is close enough to 0, 90, etc. then it won't draw
  if checkang ~= 0 and checkang ~= 90 and checkang ~= -90 and self.type ~= "circle" then
    love.graphics.arc("line", x, y, radius+radialoffset, 0, ang)

    local xpos = x + math.cos(ang)*(radius+radialoffset)
    local ypos = y + math.sin(ang)*(radius+radialoffset)

    love.graphics.circle("fill", xpos, ypos, 5)
    love.graphics.print(math.floor((-(ang*180/math.pi+180)%360-180)*100+.5)/100 .." deg", xpos, ypos-20, 0, 1.25)
  end
  if self.type == "circle" then
    local xpos = x + math.cos(ang)*(radius+radialoffset-20)
    local ypos = y + math.sin(ang)*(radius+radialoffset-20)

    love.graphics.circle("fill", xpos, ypos, 5)
  end
  radialoffset = radialoffset + 20
end

if self.showAngularVel then --ANGULAR VELOCITY
  angvel = math.floor(angvel*100+.5)/100
  local radius = 0
  if self.type == "circle" then
    radius = self.s:getRadius()
  elseif self.type == "tri" or self.type == "rect" then
    radius = math.max(self.w, self.h)/2
  end
  love.graphics.setColor(
      .94*colormultipler, .3*colormultipler, .75*colormultipler
  )

  love.graphics.arc("line", "open", x, y, radius+radialoffset, -math.pi/2, angvel/2.5-math.pi/2)

  local xpos = x + math.cos(angvel/2.5-math.pi/2)*(radius+radialoffset)
  local ypos = y + math.sin(angvel/2.5-math.pi/2)*(radius+radialoffset)
  if angvel ~= 0 then
    love.graphics.circle("fill", xpos, ypos, 5)
    love.graphics.print(angvel.." rad/s", xpos-50, ypos-20, 0, 1.25)
  end
  radialoffset = radialoffset + 20

end

if self.showAngularAcc then
  angacc = math.floor(angacc*10+.5)/10

  love.graphics.setColor(
      .45*colormultipler, .1*colormultipler, .65*colormultipler
  )
  local angaccpos = 0
  if angacc < 0 then
    angaccpos = -(math.abs(angacc)^.1)
  else
    angaccpos = (math.abs(angacc)^.1)
  end

  love.graphics.arc("line", "open", x, y, radius+radialoffset, -math.pi/2, angaccpos-math.pi/2)

  local xpos = x + math.cos(angaccpos-math.pi/2)*(radius+radialoffset)
  local ypos = y + math.sin(angaccpos-math.pi/2)*(radius+radialoffset)
  if angacc ~= 0 then
    love.graphics.circle("fill", xpos, ypos, 5)
    love.graphics.print(angacc.." rad/s²", xpos-50, ypos-20, 0, 1.25)
  end
  radialoffset = radialoffset + 20
end

if self.showVelVector then

  love.graphics.setColor(
      .4*colormultipler, .87*colormultipler, .5*colormultipler
  )

  local velVec = math.sqrt((xvel/5)^2 + (yvel/5)^2)

  local simpleVelVec = 
math.floor(math.sqrt((xvel/ppm)^2 + (yvel)^2)/ppm*100+0.5)/100
  local velAng = math.atan(yvel/xvel)
  local dir = 1
  if xvel < 0 then 
    velAng = velAng + math.pi
    dir = -1
  end


  if simpleVelVec ~= 0 then
    love.graphics.setLineWidth(6)
    love.graphics.line(
      self.xpos, self.ypos,
      self.xpos + xvel/5,
      self.ypos + yvel/5
    )

    local tripoints = {
      {velVec+10, 0},
      {velVec, 5},
      {velVec, -5}
    }

    local textPos = rotatePoint({velVec + 20, 0},  velAng)
    love.graphics.print(
      simpleVelVec .. "m/s",
      textPos[1]+self.xpos, textPos[2]+self.ypos
    )

    for i, v in ipairs(tripoints) do
      tripoints[i] = rotatePoint(v, velAng)
      tripoints[i][1] = tripoints[i][1] + self.xpos
      tripoints[i][2] = tripoints[i][2] + self.ypos
    end

    love.graphics.polygon("fill", 
    tripoints[1][1], tripoints[1][2], 
    tripoints[2][1], tripoints[2][2], 
    tripoints[3][1], tripoints[3][2]
  )


    love.graphics.setLineWidth(1)
  end

end

if self.showHeight then
    love.graphics.setColor(
        1*colormultipler, 1*colormultipler, 1*colormultipler
    )

    love.graphics.line(
    self.xpos + radius + radialoffset, self.ypos,
    self.xpos + radius + radialoffset, linepos
  )
    love.graphics.line(
    self.xpos + radius + radialoffset-6, self.ypos,
    self.xpos + radius + radialoffset+6, self.ypos
    )

    love.graphics.print(
    math.floor(self.gravpos * 100)/100 .. " m",
    self.xpos + radius + radialoffset+20, self.ypos
  )

end

if self.showDistance then
  love.graphics.setColor(
      1*colormultipler, 1*colormultipler, 1*colormultipler
  )

  love.graphics.line(
    self.xpos, self.ypos - radius - radialoffset,
    xAxis, self.ypos - radius - radialoffset
  )
  love.graphics.line(
    self.xpos, self.ypos - radius - radialoffset - 6,
    self.xpos, self.ypos - radius - radialoffset + 6
  )

  love.graphics.print(
  math.floor(((self.xpos - xAxis)/ppm)*100)/100 .. " m",
  self.xpos, self.ypos - radius - radialoffset - 20
  )

end

--DRAWS TRACE POINTS
love.graphics.setColor(
    1*colormultipler, 0, 0.42*colormultipler
)


for i, v in ipairs(self.pathTrace) do
  if self.pathTrace[i-1] then
    love.graphics.line(v[1], v[2], 
    self.pathTrace[i-1][1], self.pathTrace[i-1][2])
  end
end

end


return self
end