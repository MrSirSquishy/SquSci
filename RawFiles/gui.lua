
colormultiplier = 1
GUIS = {}

--GUI Container Class
GUI = {}
GUI.__index = GUI
function GUI:new(elements, x, y, width, height, color)
  local self = setmetatable({}, GUI)
  self.elements = elements
  self.x = x or 0
  self.y = y or 0
  self.width = width or 100
  self.height = height or 100
  self.color = color or {1,1,1}
  self.inGUI = false
  self.enabled = true

  function self:setDimensions(x, y, w, h)
    self.x = x or self.x
    self.y = y or self.y
    self.width = w or self.width
    self.height = h or self.height
  end

  --UPDATE FUNCTION
  function self:update()
    self.inGUI = false
    if self.enabled then
      local mousex = love.mouse.getX()
      local mousey = love.mouse.getY()
      local leftclick = mouseup


      --checks if mouse is within the gui
      if CheckCollision(
          mousex-2.5, mousey - 2.5,5,5,
          self.x, self.y, self.width, self.height
        ) then
        self.inGUI = true
      end

      --element updates
      local currentY = self.y
      for i, v in ipairs(self.elements) do
        currentY = currentY + v:update(self.x, currentY, self.width)
        if v.inGUI then self.inGUI = true end
      end
    end
  end

  --DRAW FUNCTION
  function self:draw()
    if self.enabled then

        love.graphics.setColor(self.color)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

        local currentY = self.y
        for i, v in ipairs(self.elements) do
          currentY = currentY + v:draw(self.x, currentY, self.width)
      end
    end
  end

  return self
end










--ELEMENTS THAT GO INSIDE OF GUIS
------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
local guiElements = {}
guiElement = {}
guiElement.__index = guiElement
function guiElement:new(func, height, color, guiType, features)
  local self = setmetatable({}, guiElement)

  self.color = color or {.2, .15, .32, 1}
  for i, v in pairs(self.color) do
    self.color[i] = self.color[i] * colormultiplier
  end
  self.func = func
  self.guiType = guiType or ""
  self.features = features or {}
  self.height = height or 50
  self.inGUI = false

  --init function
  if self.guiType == "slider" then
    self.features[1] = self.features[1] or "placeholder" --name
    self.features[2] = self.features[2] or 0 --initial value
    self.features[3] = self.features[3] or 0 --lower range
    self.features[4] = self.features[4] or 1 --upper range
    self.features[5] = 
    (self.features[2]-self.features[3])/(self.features[4]-self.features[3])  --actual position
    self.features[6] = false --local collision check variable
    self.features[7] = self.features[7] or 2 -- decimal places
    self.features[8] = textBox.new(0, 0)
    table.insert(textBoxes, self.features[8])

  elseif self.guiType == "toggle" then
    self.features[1] = self.features[1] or "placeholder" --name
    self.features[5] = false
    self.features[11] = false --oldmouseclick

  elseif self.guiType == "dropdown" then
    self.features[1] = self.features[1] or {} --gui elements
    self.features[2] = self.features[2] or "name"
    self.features[3] = self.features[3] or false --open/closed
  elseif self.guiType == "textBox" then
    self.features[1] = self.features[1] or "name"

    self.features[8] = self.features[8] or textBox.new(0, 0, nil, self.features[2])
    table.insert(textBoxes, self.features[8])

  elseif self.guiType == "selection" then
    self.features[1] = self.features[1] or {"ex1", "ex2"}
  elseif self.guiType == "button" then
    self.features[1] = self.features[1] or "placeholder"
  elseif self.guiType == "color" then
    self.features[1] = self.features[1] or "placeholder"
    self.features[2] = 0 --hovering over
    self.features[3] = false --ismousedown
  end

  --update function
  function self:update(x, y, width)
    local mousex = love.mouse.getX()
    local mousey = love.mouse.getY()
    local leftclick = mouseup

    self.inGUI = false
    if self.guiType ~= "display" and CheckCollision(
        mousex-2.5, mousey-2.5, 5, 5,
        x, y, width, self.height
    ) then
      self.inGUI = true
    end

    if self.guiType == "slider" then --Slider
      --updates text Box
      self.features[8]:update()
      if self.features[8].selected then 
        func(self.features[8].num, self.features[7])
      else
        self.features[8].setNum(func(nil, self.features[7]))
      end


      if CheckCollision(
          mousex-2.5, mousey-2.5, 5, 5, 
          x, y+self.height/2-5, width, self.height/3
      ) then
        cursor = "hand"
        if love.mouse.isDown(1) then

        local target = math.min(math.max(mousex-x-10, 0), width-20)/(width-20)
        if self.features[5] < target then
          self.features[5] =
          self.features[5] + .08*(target - self.features[5])

        elseif self.features[5] > target then
          self.features[5] =
          self.features[5] - .08*(-target + self.features[5])
        end

          do
            local num = self.features[5]*(self.features[4]-self.features[3])+self.features[3]

            func(
                num,
                self.features[7]
            )

          end
        end
      end
    --TOGGLE TYPE
    elseif self.guiType == "toggle" then
      self.features[5] = false
      if CheckCollision(
          mousex - 2.5, mousey - 2.5, 5, 5,
          x+5, y+5, self.height - 10, self.height - 10
      ) then
        self.features[5] = true
        cursor = "hand"
        if leftclick then
          self.features[5] = false
          if not self.features[11] then
            func(true)
          end
        end
      end


      self.features[11] = leftclick --oldleftclick

    --DROPDOWN TYPE
    elseif self.guiType == "dropdown" then

      if leftclick and not self.features[11] then
        if CheckCollision(
            mousex-2.5, mousey-2.5, 5, 5,
            x,y,width,self.height
        ) then 
          self.features[3] = not self.features[3]
        end
      end

      local add = 0
      if self.features[3] then
        for i, v in ipairs(self.features[1]) do
          add = add + v:update(x+5, y+self.height+add, width-5)
          if v.inGUI then self.inGUI = true end
        end
      end

      self.features[11] = leftclick
      return self.height + add

    elseif self.guiType == "textBox" then
      if self.features[8].selected then 
        if self.features[2] == false then
          func(self.features[8].input)
        else
          func(self.features[8].num)
        end

      else
        self.features[8].setNum(func())
      end

    elseif self.guiType == "selection" then
      local ypos = y
      self.features[2] = nil
      for i, v in ipairs(self.features[1]) do

        if CheckCollision(
            mousex-2.5, mousey-2.5, 5, 5,
            x,ypos,
            width,self.height/#self.features[1]
        ) then 
          self.features[2] = i
          if leftclick then
            func(i)

          end
        end
        ypos = ypos + self.height/#self.features[1]
      end

    elseif self.guiType == "button" then
      self.features[3] = false
      if CheckCollision(
          mousex-2.5, mousey-2.5, 5, 5, 
          x, y+self.height/2-5, width, self.height/3
      ) then
        self.features[2] = true
        if leftclick then
          func()
          self.features[3] = true
        end
      else
        self.features[2] = false
      end

    elseif self.guiType == "color" then

      local colors, colorIndex = func()
      local sq = width/#colors
      self.features[2] = 0
      self.features[3] = false

      for i = 0, #colors - 1 do
        if CheckCollision(
            mousex-2.5, mousey-2.5, 5, 5,
            x+i*sq,y+8,sq,sq
        ) then 
          self.features[2] = i + 1
          if leftclick then
            self.features[3] = true
            func(i+1)
          end
        end
      end



    end

    return(self.height)
  end

  --draw function
  --------------------------------------
  --------------------------------------
  --------------------------------------
  --------------------------------------
  function self:draw(x, y, width)

    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", x, y, width, self.height)
    if self.guiType == "slider" then --SLIDER

      self.features[8].x = x
      self.features[8].y = y+self.height - 15
      self.features[8].width = width
      self.features[8]:draw()

      love.graphics.setColor(
        .3*colormultipler,.9*colormultipler,1*colormultipler
      )
      love.graphics.rectangle(
        "fill", x+10, y+25, width - 20, 5
      )
      love.graphics.setColor(
        1*colormultiplier,1*colormultiplier,1*colormultiplier
      )
      local circlePos = 
      math.max(math.min(((func(nil, self.features[7]) - self.features[3])/(self.features[4]-self.features[3]))*(width-20)+x+10, x+width-7.5), x+7.5)

      love.graphics.circle("fill", 
        circlePos, 
        y+27.5, 5
      )
      love.graphics.print(self.features[1], x+2.5, y+2.5)
      do
        --love.graphics.print(""..func(nil, self.features[7]), x+2.5, y + self.height - 15)
      end

    elseif self.guiType == "textBox" then --TEXTBOX DRAW
      self.features[8].x = x
      self.features[8].y = y+15
      self.features[8].width = width
      self.features[8].height = self.height-18
      self.features[8]:draw()

      love.graphics.print(self.features[1], x, y)

    --TOGGLE TYPE DRAW
    elseif self.guiType == "toggle" then
      local filled = "line"
      if func() then 
        filled = "fill"
      end

      love.graphics.setColor(
        1*colormultiplier, 1*colormultiplier, 1*colormultiplier)
      love.graphics.print(self.features[1], 
        x+2.5+self.height, y+self.height/2 - 5
      )

      if self.features[5] then
        love.graphics.setColor(
          .8*colormultiplier, .8*colormultiplier, .8*colormultiplier)
      end 


      love.graphics.rectangle(filled,
        x+5, y+5, self.height - 10, self.height - 10
      )

    elseif self.guiType == "display" then
      love.graphics.setColor(
        1*colormultiplier, 1*colormultiplier, 1*colormultiplier)

      love.graphics.print(func(), x+2.5, y+2.5)

    elseif self.guiType == "dropdown" then



      local str = ">"
      local add = 0
      if self.features[3] then
        for i, v in ipairs(self.features[1]) do
          add = add + v:draw(x+5, y+self.height+add, width-5)
        end 
        str = "v "
      end
      love.graphics.setColor(
        1*colormultiplier, 1*colormultiplier, 1*colormultiplier)
      love.graphics.print(str .. "  " .. self.features[2], x+10.5, y+5)
      love.graphics.rectangle("line", x+8, y+6, 13, 13)

      local mousex = love.mouse.getX()
      local mousey = love.mouse.getY()
      if CheckCollision(
          mousex-2.5, mousey-2.5, 5, 5,
          x,y,width,self.height
      ) then 
        love.graphics.setColor(
          .75*colormultiplier, .75*colormultiplier, .75*colormultiplier)
      end
      love.graphics.rectangle("line", x+1,y,width-1,self.height)

      return(self.height + add)
    elseif self.guiType == "selection" then
      local current = func(i)
      local ypos = y
      local height = self.height/#self.features[1]
      for i, v in ipairs(self.features[1]) do

        if i == current then
          love.graphics.setColor(
            .9*colormultiplier, 
            .9*colormultiplier, 
            .9*colormultiplier)
        elseif i == self.features[2] then
          love.graphics.setColor(
            .75*colormultiplier, 
            .75*colormultiplier, 
            .75*colormultiplier)
        else
          love.graphics.setColor(
            .6*colormultiplier, 
            .6*colormultiplier, 
            .6*colormultiplier)
        end

        love.graphics.rectangle("fill", 
          x, ypos, 
          width, height)

        love.graphics.setLineWidth(3)
        love.graphics.setColor(self.color)
        love.graphics.rectangle("line", 
          x, ypos, 
          width, height)
        love.graphics.setLineWidth(1)

        if i == current then
          love.graphics.setColor(
            0*colormultiplier, 
            0*colormultiplier, 
            0*colormultiplier)

        else
          love.graphics.setColor(
            1*colormultiplier, 
            1*colormultiplier, 
            1*colormultiplier)
        end
        love.graphics.print(v, x+10, ypos+height/2 - 5)

        ypos = ypos + height
      end
    elseif self.guiType == "button" then

      if self.features[3] then
        love.graphics.setColor(
          .9*colormultiplier, 
          .9*colormultiplier, 
          .9*colormultiplier)
      elseif self.features[2] then
        love.graphics.setColor(
          .75*colormultiplier, 
          .75*colormultiplier, 
          .75*colormultiplier)
      else
        love.graphics.setColor(
          .6*colormultiplier, 
          .6*colormultiplier, 
          .6*colormultiplier)
      end

      love.graphics.rectangle("fill", 
        x, y, 
        width, height)

      love.graphics.setLineWidth(3)
      love.graphics.setColor(self.color)
      love.graphics.rectangle("line", 
        x, y, 
        width, height)
      love.graphics.setLineWidth(1)

      if self.features[3] then
        love.graphics.setColor(
          0*colormultiplier, 
          0*colormultiplier, 
          0*colormultiplier)

      else
        love.graphics.setColor(
          1*colormultiplier, 
          1*colormultiplier, 
          1*colormultiplier)
      end
      love.graphics.print(self.features[1], x+10, y+height/2 - 5)


    elseif self.guiType == "color" then
      local colors, colorIndex = func()
      local sq = width/#colors
      for i, v in ipairs(colors) do
        if i == self.features[2] or i == colorIndex or self.features[3] then
          love.graphics.setColor(1,1,1)
          love.graphics.rectangle("fill",
            x+(i-1)*sq, y+8, sq, sq
          )
        end

        love.graphics.setColor(v)
        love.graphics.rectangle("fill",
          x+(i-1)*sq+2.5, y+8+2.5, sq-5, sq-5
        )

      end
      --self.features[3] = leftclick
    end


    return self.height
  end

  return self
end
--simplified creation to append to list
function newGUIElement(func, height, color, guiType, features)
  table.insert(guiElements, 
    guiElement:new(func, height, color, guiType, features)
  )
end

--FUNCTIONS FOR GUIS
function Gravity(gravity, incr)
    incr = incr or 1
    if gravity then
        world:setGravity(0,(math.floor(gravity / incr) * incr)*ppm)
    end
    local _, y = world:getGravity()
    return math.floor((y/ppm/incr)*10 + .5)/10*incr
end

function setFluidDensity(val, incr)
  incr = incr or 1
  if val then
    FluidDensity = val
  end
  return math.floor(FluidDensity*100 + .5)/100
end

function timeSpeed(time, incr)
  incr = incr or 1

  if time then
    if time > 1 then 
      time = math.ceil(time)
    end
    time = math.min(time, 10)
    timespeed = (math.floor(time/incr)*incr)
  end
  return math.floor((timespeed/incr)*100 + .5)/100*incr
end

--textBox test function
testVar = 0
function test(val)
  if val then
    testVar = val
  end
  return testVar
end

forceVelVectors = false
forceAccVectors = false
forceAngVectors = false
forceAngVelVectors = false
forceAngAccVectors = false
--vel
function toggleVelVectors(toggle)
  if toggle then
    forceVelVectors = not forceVelVectors
    for i, v in ipairs(objects) do
      objects[i].showVel = forceVelVectors
    end
  end

  return forceVelVectors
end
--acc
function toggleAccVectors(toggle)
  if toggle then
    forceAccVectors = not forceAccVectors
    for i, v in ipairs(objects) do
      objects[i].showAcc = forceAccVectors
    end
  end

  return forceAccVectors
end
--ang
function toggleAng(toggle)
  if toggle then
    forceAngVectors = not forceAngVectors
    for i, v in ipairs(objects) do
      objects[i].showAngle = forceAngVectors
    end
  end

  return forceAngVectors
end
--angvel
function toggleAngVel(toggle)
  if toggle then
    forceAngVelVectors = not forceAngVelVectors
    for i, v in ipairs(objects) do
      objects[i].showAngularVel = forceAngVelVectors
    end
  end

  return forceAngVelVectors
end

--X and Y Pos
forceXPos = false
function toggleXPos(toggle)
  if toggle then
    forceXPos = not forceXPos
    for i, v in ipairs(objects) do
      objects[i].showDistance = forceXPos
    end
  end

  return forceXPos
end
forceYPos = false
function toggleYPos(toggle)
  if toggle then
    forceYPos = not forceYPos
    for i, v in ipairs(objects) do
      objects[i].showHeight = forceYPos
    end
  end

  return forceYPos
end

forceVelDirVector = false
function toggleDirVector(toggle)
  if toggle then
    forceVelDirVector = not forceVelDirVector
    for i, v in ipairs(objects) do
      objects[i].showVelVector = forceVelDirVector
    end
  end

  return forceVelDirVector
end

--Trace Paths
forcePaths = false
function togglePaths(toggle)
  if toggle then
    forcePaths = not forcePaths
    for i, v in ipairs(objects) do
      objects[i].showPath = forcePaths
    end
  end

  return forcePaths
end

--angacc
function toggleAngAcc(toggle)
  if toggle then
    forceAngAccVectors = not forceAngAccVectors
    for i, v in ipairs(objects) do
      objects[i].showAngularAcc = forceAngAccVectors
    end
  end

  return forceAngAccVectors
end

--movetime
function toggleMoveTime(toggle)
  if toggle then
    movetime = not movetime
  end

  return movetime
end

--globalgravity

function toggleGravity(toggle)
  if toggle then
    GravitationalForces = not GravitationalForces
  end

  return GravitationalForces
end

function toggleXAxis(toggle)
  if toggle then
    xAxisEnabled = not xAxisEnabled
  end
  return xAxisEnabled
end

selectionNum = 1
function selection(num)
  if num then
    selectionNum = num
  end
  return selectionNum
end



--saveload
filename = "SimulationName"
function setFileName(val)
  if val then
    filename = val
  end
  return filename
end

function SAVE()
  local savedata = "$" .. filename .. "@"
  for i, v in pairs(objects) do
    local unique = ""
    if v.type == "circle" then
      unique = v.radius/ppm
    else
      unique = v.w/ppm .. " " .. v.h/ppm
      print(unique)
    end
    local velx, vely = v.b:getLinearVelocity()
    savedata = savedata
    .. " " .. v.type
    .. " " .. v.name
    .. " " .. v.bodytype
    .. " " .. v.b:getX()
    .. " " .. v.b:getY()
    .. " " .. unique
    .. " " .. velx
    .. " " .. vely
    .. " " .. v.b:getAngle()
    .. " " .. v.b:getAngularVelocity()
    .. " " .. v.mass
    .. " " .. v.friction
    .. " " .. v.restitution
    .. " " .. v.color[1]
    .. " " .. v.color[2]
    .. " " .. v.color[3]
    .. " " .. "@"

  end
  
  love.filesystem.write(filename..".txt", savedata)
end
--rect/tri
--1type, 2name, 3dynamic, 4x, 5y, 6w, 7h, 8vx, 9vy, 10a, 11av, 12m, 13f, 14resti, r g b
--circle
--type, name, dynamic, x, 5y, 6r, 7vx, 8vy, 9a, 10av, 11m, 12f, 13resti r g b

function openSaves()
  love.system.openURL("file://"..love.filesystem.getSaveDirectory())
end

MassMultiplier = 1
MassUnit = "Kg"
MassNum = 2
function setMassUnit(num)

  if num then
  
  self.inertiaTypeNum = num
  if self.inertiaTypeNum == 1 then
    MassMultiplier = 0.001
    MassUnit = "g"
    MassNum = 1
  elseif self.inertiaTypeNum == 2 then
    MassMultiplier = 1
    MassUnit = "Kg"
    MassNum = 2
  elseif self.inertiaTypeNum == 3 then
    MassMultiplier = 1000
    MassUnit = "Tonne"
    MassNum = 3
  elseif self.inertiaTypeNum == 4 then
    MassMultiplier = 1000000000
    MassUnit = "MegaTonne"
    MassNum = 4
  end
  
  end
  
  
  return MassNum or 1
  end

  function savea()
    saveAttributes(GlobalAttributeMemory)
  end
  function loada()
    loadAttributes(GlobalAttributeMemory)
  end


--features guide
--SLIDER: name, initial value, lower range, upper range, actual, ignore, multiples of
--creating GUI Elements



mainGUI = GUI:new(
  {
    guiElement:new(function() currentPage = "Main Page" end, 40, nil, "button",
          {"Return to Menu"}),
    guiElement:new(setFileName, 35, nil, "textBox", 
          {"Simulation Name", false}),
    guiElement:new(SAVE, 25, nil, "button",
          {"Save"}),
    guiElement:new(openSaves, 25, nil, "button",
          {"Open Saves"}),
    guiElement:new(Gravity, 50, nil, "slider",
      {"Gravity (m/s²)", 9.8, 0, 50.1, nil, nil, .1}),
    guiElement:new(toggleMoveTime, 30, nil, "toggle",
      {"Time Moving(Space)"}),
    guiElement:new(timeSpeed, nil, nil, "slider",
    {"Time Speed", 1, 0.001, 5, nil, nil, .05}),
    --guiElement:new(setFluidDensity, nil, nil, "slider",
      --{"Fluid Density (Kg/m³)", 0, 0, 10, nil, nil, .01}),
    guiElement:new(nil, 25, nil, "dropdown", {{
      guiElement:new(togglePaths, 25, nil, "toggle",
        {"Trace Paths"}),
      guiElement:new(toggleXPos, 25, nil, "toggle",
        {"Show Distances"}),
      guiElement:new(toggleYPos, 25, nil, "toggle",
        {"Show Heights"})
    }, "Position Features", false}),

    guiElement:new(nil, 25, nil, "dropdown", {{
      guiElement:new(toggleVelVectors, 25, nil, "toggle",
        {"Velocity Vectors"}),
      guiElement:new(toggleAccVectors, 25, nil, "toggle",
        {"Acceleration Vectors"}),
      guiElement:new(toggleDirVector, 25, nil, "toggle",
        {"Velocity Dir Vector"}),
    }, "Linear Dynamics", false}),
    
    guiElement:new(nil, 25, nil, "dropdown", {{
      guiElement:new(toggleAng, 25, nil, "toggle", 
        {"Display Angle"}),
      guiElement:new(toggleAngVel, 25, nil, "toggle", 
        {"Display Ang Vel"}),
      guiElement:new(toggleAngAcc, 25, nil, "toggle", 
        {"Display Ang Acc"}),
    }, "Angular Dynamics", false}),
    
    guiElement:new(toggleGravity, 30, nil, "toggle", 
      {"Global Gravity"}),
    guiElement:new(nil, 25, nil, "dropdown", {{
      guiElement:new(setMassUnit, 90, nil, "selection", {{
              "g",
              "Kg",
              "Tonne",
              "MegaTonne"
      }})
}, "Mass Units", false}),
    guiElement:new(savea, 25, nil, "button",
        {"Save State(s)"}),
    guiElement:new(loada, 25, nil, "button",
        {"Load State(l)"}),
  },
  love.graphics.getWidth()-175, 0, 150, love.graphics.getHeight(), {.2*colormultiplier,.15*colormultiplier, .32*colormultiplier}
)





local mouseoffset = 0
local wasleftclick = false
--RUNS ALL GUI STUFF
function updateGUI(dt)
  local inGUI = false
  local mousex = love.mouse.getX()
  local mousey = love.mouse.getY()
  local leftclick = mouseup

  --main GUI updates
  mainGUI:update()
  if mainGUI.inGUI then inGUI = true end

  --GUI Updates
  for i, v in ipairs(GUIS) do
    v:update()
    if v.inGUI then inGUI = true end
  end


  --drag mainGUI size
  mainGUI.width = love.graphics.getWidth() - mainGUI.x
  mainGUI.height = love.graphics.getHeight()
  mainGUI.x = love.graphics.getWidth()-175-mouseoffset
  --[[


  if CheckCollision(
      mousex-4, mousey-4, 8, 8,
      mainGUI.x-10, mainGUI.y, 15, mainGUI.height
  ) then
    inGUI = true
    cursor = "sizewe"
    if love.mouse.isDown(1) then
      mainGUI.x = mouseoffset
      mainGUI.width = love.graphics.getWidth() - mouseoffset
    end
  end]]

  wasleftclick = leftclick
  return inGUI
end


--DRAWS GUI ELEMENTS
function drawGUI()


  for i, v in ipairs(GUIS) do
    v:draw()
  end
  mainGUI:draw()
end

