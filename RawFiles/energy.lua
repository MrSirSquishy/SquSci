--Handles energy system. 
local love = require("love")

--global position for ground gravity line
linepos = 300
xAxis = 0

totalKinetic = 0
totalPotential = 0
totalEnergy = 0

xAxisEnabled = true

--UPDATE FUNCTION
---------------------------------------------------
function updateEnergy(dt)
  totalPotential = 0
  totalKinetic = 0

  for i, v in ipairs(objects) do
    totalPotential = totalPotential + v.UG
    totalKinetic = totalKinetic + v.KL + v.KR


    if v.name == "floor" then --updates line position
      linepos = v.b:getY()-v.h/2
    end
  end

  totalEnergy = totalPotential + totalKinetic
  --print(totalEnergy)
end




--DRAW FUNCTION
-----------------------------------------------------
local oldcamx = camx
local linimate = 0
function drawEnergy()





  love.graphics.setColor(colormultiplier, colormultiplier, colormultiplier)
  --ground line position
  --animated line
  linimate = linimate + 1
  if linimate > 30 or linimate < -30 then
    linimate = 0
  end

  love.graphics.print("x-axis", 
    10, (linepos+camy+10)*camscale, 
    0, 1.25)
  for i = -15,love.graphics.getWidth(),30 do
    love.graphics.line(i+linimate,(linepos+camy)*camscale,i+15+linimate,(linepos+camy)*camscale)
  end

  if xAxisEnabled then 
    love.graphics.print("y-axis", camx*camscale+10, 10, 0, 1.25)
    for i = -15,love.graphics.getWidth(),30 do
      love.graphics.line((xAxis + camx)*camscale, i+linimate, (xAxis + camx)*camscale, i+15+linimate)
    end
  end


  oldcamx = camx
end



