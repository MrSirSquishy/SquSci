currentPage = "Main Page"
--PHYSICS < code word for simulation

--easing interpolation function(s)
function easeOutQuint(t)
  return 1 - math.pow(1 - math.max(math.min(t, 1), 0), 5)
end



pages = {}
page = {}
page.__index = page
function page:new(name, elements, color)
  local self = setmetatable({}, page)
  self.name = name or "none"
  self.elements = elements or {}
  self.color = color or {0, 0 ,0}
  self.activetime = 0
  self.hover = -1

  function self.update(dt)


    if currentPage == self.name then
      self.activetime = self.activetime + 1
      local x = love.mouse:getX()
      local y = love.mouse:getY()
      local w = love.graphics.getWidth()
      local h = love.graphics.getHeight()
      local leftclick = love.mouse.isDown(1)

      local n = 0
      self.hover = -1
      for i, v in ipairs(elements) do 
      local xpos = 
        easeOutQuint(self.activetime/100 - n/10)*(3*w/4) - w/2

      if v[1] and CheckCollision( 
        xpos, n*50 + h/5, w/2, 50,
        x-2.5, y-2.5, 5, 5
      ) then
          self.hover = i
          if mouseup then
            v[1]()
          end
        end

        n = n + 1
      end
    else
      self.activetime = easeOutQuint(self.activetime)
    end

  end

  function self.draw()

    if currentPage == self.name then
      local w = love.graphics.getWidth()
      local h = love.graphics.getHeight()

      love.graphics.setColor(self.color)
      love.graphics.rectangle("fill", 0, 0, 
        w,
        easeOutQuint(self.activetime/100)*h
      )

      love.graphics.setColor(1,1,1)
      local n = 0
      for i, v in ipairs(elements) do
        local fill = "line"
        if self.hover == i then
          fill = "fill"
        end
        local xpos = 
        easeOutQuint(self.activetime/100 - n/10)*(3*w/4) - w/2
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle(fill, 
          xpos, n*50 + h/5, w/2, 50
        )
        if self.hover == i then
          love.graphics.setColor(0,0,0)
        end
        --love.graphics.circle("fill", xpos, n*50 + h/5 + 25, 10)
        --love.graphics.circle("fill", xpos+w/2, n*50 + h/5 + 25, 10)
        love.graphics.printf(v[2], 
          xpos - w/2, n*50 + h/5, 
          w, "center", 0, 1.5)
        n = n + 1
      end

      love.graphics.setColor(1,1,1)
      love.graphics.print(name, 10, 10, 0, 1.5, 1.5)

    
    end



  end

  pages[name] = self
  return self
end





page:new("Main Page", {
    {
      function()
        currentPage = "New Simulation"
      end,
      "New Simulation"
    },
    {
      function ()
        love.event.quit()
      end,
      "Quit"
    }
}, 
  {0.11, 0.14, 0.33})

function addContinue()
  if pages["Main Page"].elements[1][2] ~= "Continue Sim" then
    table.insert(pages["Main Page"].elements, 1, 
    {
        function()
          currentPage = "PHYSICS"
        end,
        "Continue Sim"
    })
  end
end

page:new("New Simulation", {
  {
    function()
      currentPage = "PHYSICS"
      clearList(objects)
      addContinue()
    end,
    "Empty"
  },
    {
      function()
        currentPage = "PHYSICS"
        clearList(objects)
        table.insert(objects, rect.new("floor", -100000/2, 500, 100000, 10, "static", 1, 0, 0.5, "fill", {.5,.5,.5,1}))
        addContinue()
      end,
      "Floor"
    },
    {
      function()
        currentPage = "PHYSICS"
        clearList(objects)
        addContinue()
        table.insert(objects, rect.new("floor", -100000/2, 1000, 100000, 10, "static", 1, 0, 0.5, "fill", {.5,.5,.5,1}))
        table.insert(objects, rect.new("rect2", 300, 100, 1, 1, "dynamic", 1, .5, 0.5, "fill", {1,1,0,1}))
        table.insert(objects, rect.new("rect3", 400, 100, 1, 1, "dynamic", 1, .5, 0.5, "fill", {1,1,0,1}))
        table.insert(objects, circle.new("ball1", 200, 0, 1, "dynamic", "fill", 1, .8, 0.5, {0, 1, 1, 1}))
        table.insert(objects, tri.new("tri2", 200, 200, 5, 3, "dynamic", 1, .5, 0.5, "fill", {1,1,1,1}))

      end,
      "Simple"
    },

  {
    nil,
    "Drag/Drop sim files to open"
  },
  {
    openSaves,
    "Open Saves Folder"
  },
  {
    function()
      currentPage = "Main Page"
    end,
    "Back"
  }
}, 
{0.16, 0.44, 0.87})



--Open Simulation
--  Empty Simulation
--  Load Simulation