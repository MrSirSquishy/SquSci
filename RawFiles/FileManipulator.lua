file = nil
function love.filedropped(f)
if (currentPage == "New Simulation" or currentPage == "Main Page") and f:getExtension() == "txt" then
file = f
file:open("r") --opens in read
local data = file:read()
--print("noticed")
--print(file:getFilename(), " -- ", data)


currentPage = "PHYSICS"
clearList(objects)
addContinue()


--loading elements portion
local attributememory = {}
local i = 1
while i < #data do

  if data:sub(i,i) == "@" then --start of an object
    local obj = {}
    local j = 1
    local num = 0
    while j + i < #data and data:sub(j + i,j + i) ~= "@" do
      local ij = i + j

      if data:sub(j + i,j + i) == " " then --start of item
        num = num + 1
        local k = 1
        local piece = ""
        while k + ij < #data and data:sub(k + ij, k +ij) ~= " " and data:sub(k + ij, k +ij) ~= "@"  do
          piece = piece .. data:sub(k + ij,k + ij)
          k = k + 1
        end

        local referenceType = #obj + 1


        if loadReferenceList[num] == 0 then --int

          piece = tonumber(piece)
        elseif loadReferenceList[num] == 1 then --str

        else --array

        end

        if piece ~= "" then
          table.insert(obj, piece)
        end
      end
      j = j + 1


    end
    table.insert(attributememory, obj)

  elseif data:sub(i,i) == "$" then
    local j = i + 1
    local savename = ""

    while j < #data and data:sub(j,j) ~= "@" do
      savename = savename .. data:sub(j,j)
      j = j + 1
    end
    filename = savename
  end

  i = i + 1
end

for i, v in pairs(attributememory) do
  if v[1] == "rect" then
    local obj = rect.new(v[2] .. "L", v[4], v[5], v[6], v[7], v[3], v[12], v[14], v[13], nil, {v[15], v[16], v[17]})
    obj.b:setLinearVelocity(v[8], v[9])
    obj.b:setAngle(v[10])
    obj.b:setAngularVelocity(v[11])
    table.insert(objects, obj)
  elseif v[1] == "tri" then
    local obj = tri.new(v[2] .. "L", v[4], v[5], v[6], v[7], v[3], v[12], v[14], v[13], nil, {v[15], v[16], v[17]})
    obj.b:setLinearVelocity(v[8], v[9])
    obj.b:setAngle(v[10])
    obj.b:setAngularVelocity(v[11])
    table.insert(objects, obj)
  elseif v[1] == "circle" then
    local obj = circle.new(v[2] .. "L", v[4], v[5], v[6], v[3], nil, v[11], v[13], v[12], {v[14], v[15], v[16]})
    obj.b:setLinearVelocity(v[7], v[8])
    obj.b:setAngle(v[9])
    obj.b:setAngularVelocity(v[10])
    table.insert(objects, obj)
  end
    
end

file:close()
end
end
--rect/tri
--1type, 2name, 3dynamic, 4x, 5y, 6w, 7h, 8vx, 9vy, 10a, 11av, 12m, 13f, 14resti, r g b
--circle
--type, name, dynamic, x, 5y, 6r, 7vx, 8vy, 9a, 10av, 11m, 12f, 13resti r g b


--Name, X, Y, VelX, VelY, angle, angvel, b.inertia, inertia, mass, b.mass, friction, restituition, bodytype, path
--0 = int, 1 = string, 2 = list
loadReferenceList = {1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}



--TEMPRORARY MEMORY
GlobalAttributeMemory = {}
function saveAttributes(AttributeMemory)
for i, v in ipairs(objects) do
local vel1, vel2 = v.b:getLinearVelocity()
local path = {}
for j, k in ipairs(v.pathTrace) do
table.insert(path, k)
end

AttributeMemory[i] = {
v.name,
v.b:getX(),
v.b:getY(),
vel1,
vel2,
v.b:getAngle(),
v.b:getAngularVelocity(),
v.b:getInertia(),
v.inertia,
v.b:getMass(),
v.b:getMass(),
v.friction,
v.restitution,
v.bodytype,
path
} 


end
return AttributeMemory
end

function loadAttributes(AttributeMemory)
for i in ipairs(objects) do
local exists = false
for _, v in ipairs(AttributeMemory) do
if objects[i].name == v[1] then
exists = true
objects[i].b:setX(v[2])
objects[i].b:setY(v[3])
objects[i].b:setLinearVelocity(v[4], v[5])
objects[i].b:setAngle(v[6])
objects[i].b:setAngularVelocity(v[7])
objects[i].b:setInertia(v[8])
objects[i].inertia = v[9]
objects[i].mass = v[10]
objects[i].setMass(v[11])
objects[i].friction = v[12]
objects[i].restitution = v[13]
  for j, _ in pairs(objects[i].pathTrace) do 
    objects[i].pathTrace[j] = nil 
  end
  for j, k in ipairs(v[15]) do
    table.insert(objects[i].pathTrace, k)
  end

break
end
end
if not exists then
objects[i].b:destroy()
table.remove(objects, i)
end
end
end

function clearList(a)
for i in ipairs(a) do
  a[i].f:destroy()
  a[i].b:destroy()
  a[i] = nil
end
end


--[[

$SimulationName@ rect floor static -50000 499.99996948242 rect  0 0 0 0 1 0.5 0 0.5 0.5 0.5 @ rect rect2 dynamic 270.65710449219 224.51628112793 rect  2.5145709514618e-07 6.7055225372314e-07 0.0013491548597813 9.5424166346447e-09 1 0.5 0.5 1 1 0 @ rect rect3 dynamic 321.96469116211 224.44738769531 rect  -2.2351741790771e-07 2.2351741790771e-07 -1.5707556009293 -9.7599990311892e-09 1 0.5 0.5 1 1 0 @ circle ball1 dynamic -174.97468566895 197.57272338867 circle 50 -110.97842407227 -11.082908630371 -8.0156660079956 -2.2268621921539 1 0.5 0.8 0 1 1 @ tri tri2 dynamic 205.57150268555 44.038394927979 tri  0.030667012557387 -0.049467086791992 0.011972091160715 0.00059793808031827 1 0.5 0.5 1 1 1 @

]]