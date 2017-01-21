METER_IN_PX = 600
FALLBESCHLEUNIGUNG = 9.81
KNOBS_SIZE = 30

MW_WIDTH = 400
MW_HEIGHT = 300
MW_MASS_IN_KG = 6
MW_DOOR_MASS_IN_KG = 2
MW_KNOB_MASS_IN_KG = 1
KITCHEN_HEIGHT = 50

DEGREE_PER_S = 30

currentObj = nil

MW_CATEGORY = 1
CAT_CATEGORY = 2
DING_ONCE = true

WATTS = {}
WATTS[0] = 200
WATTS[360] = 200
WATTS[90] = 400
WATTS[180] = 600
WATTS[270] = 700

NON_COLLIDE_GRP = -31337

DEBUG = 0

function love.load()
  gameWidth = 800
  gameHeight = 600
  screenWidth = gameWidth
  screenHeight = gameHeight
  tX = 0
  tY = 0
  scaleFactor = 1.0
  love.resize(gameWidth, gameHeight)

  love.physics.setMeter(METER_IN_PX)
  world = love.physics.newWorld(0, FALLBESCHLEUNIGUNG * METER_IN_PX, true)
  power = 0

  objects = {}

  objects.kitchen = {}
  objects.kitchen.body = love.physics.newBody(world, 800 / 2, 600 - KITCHEN_HEIGHT / 2, "static")
  objects.kitchen.shape = love.physics.newRectangleShape(800, KITCHEN_HEIGHT)
  objects.kitchen.fixture = love.physics.newFixture(objects.kitchen.body, objects.kitchen.shape)
  objects.kitchen.fixture:setFriction(1.0)
  objects.kitchen.background = love.graphics.newImage("kueche.png")

  objects.mwbody = {}
  objects.mwbody.body = love.physics.newBody(world, 800 / 2, 600 - MW_HEIGHT / 2 - KITCHEN_HEIGHT, "static")
  objects.mwbody.body:setMass(MW_MASS_IN_KG)
  objects.mwbody.shape = love.physics.newRectangleShape(MW_WIDTH, MW_HEIGHT)
  objects.mwbody.fixture = love.physics.newFixture(objects.mwbody.body, objects.mwbody.shape)
  objects.mwbody.fixture:setFriction(1.0)
  objects.mwbody.fixture:setCategory(MW_CATEGORY)
  objects.mwbody.fixture:setGroupIndex(NON_COLLIDE_GRP)
  objects.mwbody.image = love.graphics.newImage("mwbody.png")
  --objects.mwbody.ding = love.sound.newSoundData("ding.mp3")
  objects.mwbody.ding = love.audio.newSource("ding.mp3", "static")

  objects.mwdoor = {}
  objects.mwdoor.body = love.physics.newBody(world, 700 / 2, 600 - MW_HEIGHT / 2 - KITCHEN_HEIGHT, "dynamic")
  objects.mwdoor.body:setMass(MW_DOOR_MASS_IN_KG)
  objects.mwdoor.body:setUserData(objects.mwdoor)
  objects.mwdoor.shape = love.physics.newRectangleShape(300, 300)
  objects.mwdoor.fixture = love.physics.newFixture(objects.mwdoor.body, objects.mwdoor.shape)
  objects.mwdoor.fixture:setFriction(0.1)
  objects.mwdoor.fixture:setCategory(MW_CATEGORY)
  objects.mwdoor.fixture:setGroupIndex(NON_COLLIDE_GRP)
  local x, y = objects.mwbody.body:getWorldCenter()
  objects.mwdoor.mwjoint = love.physics.newPrismaticJoint( objects.mwbody.body, objects.mwdoor.body, x, y, 1, 0, false )
  objects.mwdoor.mwjoint:setLimitsEnabled(true)
  objects.mwdoor.mwjoint:setLimits( -288, -2 )
  --objects.mwdoor.mwmaxjoint = love.physics.newRopeJoint( objects.mwbody.body, objects.mwdoor.body, x, y, x, y, 300, false )
  objects.mwdoor.image = love.graphics.newImage("mwdoor.png")
  objects.mwdoor.body:applyLinearImpulse(-400, 0)
  objects.mwdoor.open = false

  objects.mwwatts = {}
  objects.mwwatts.body = love.physics.newBody(world, 800 - 200 - 100 / 2, 600 - KITCHEN_HEIGHT - 300 + 50, "static")
  objects.mwwatts.body:setUserData(objects.mwwatts)
  objects.mwwatts.body:setAngle(0)
  objects.mwwatts.shape = love.physics.newCircleShape(KNOBS_SIZE)
  objects.mwwatts.fixture = love.physics.newFixture(objects.mwwatts.body, objects.mwwatts.shape)
  objects.mwwatts.fixture:setFriction(1.0)
  objects.mwwatts.fixture:setCategory(MW_CATEGORY)
  --objects.mwwatts.fixture:setGroupIndex(NON_COLLIDE_GRP)
  objects.mwwatts.mwjoint = love.physics.newRevoluteJoint( objects.mwwatts.body, objects.mwbody.body, 800 - 200 - 100 / 2, 600 - KITCHEN_HEIGHT - 300 + 50, false )
  objects.mwwatts.mousejoint = love.physics.newMouseJoint(objects.mwwatts.body, love.mouse.getPosition())
  objects.mwwatts.image = love.graphics.newImage("mwknob.png")

  objects.mwtime = {}
  objects.mwtime.body = love.physics.newBody(world, 800 - 200 - 100 / 2, 600 - KITCHEN_HEIGHT - 300 + 150, "static")
  objects.mwtime.body:setUserData(objects.mwtime)
  objects.mwtime.shape = love.physics.newCircleShape(KNOBS_SIZE)
  objects.mwtime.fixture = love.physics.newFixture(objects.mwtime.body, objects.mwtime.shape)
  objects.mwtime.fixture:setFriction(1.0)
  objects.mwtime.fixture:setCategory(MW_CATEGORY)
  --objects.mwtime.fixture:setGroupIndex(NON_COLLIDE_GRP)
  objects.mwtime.mwjoint = love.physics.newRevoluteJoint( objects.mwtime.body, objects.mwbody.body, 800 - 200 - 100 / 2, 600 - KITCHEN_HEIGHT - 300 + 150, false )
  objects.mwtime.mousejoint = love.physics.newMouseJoint(objects.mwtime.body, love.mouse.getPosition())
  objects.mwtime.image = love.graphics.newImage("mwknob.png")

  -- Cat
  objects.catbody = {}
  objects.catbody.body = love.physics.newBody(world, 600, 100, "static")
  objects.catbody.body:setUserData(objects.catbody)
  objects.catbody.shape = love.physics.newRectangleShape(120, 70)
  objects.catbody.fixture = love.physics.newFixture(objects.catbody.body, objects.catbody.shape)
  --objects.catbody.fixture:setGroupIndex(NON_COLLIDE_GRP)
  objects.catbody.image = love.graphics.newImage("cat_body.png")
  objects.cathead = {}
  objects.cathead.body = love.physics.newBody(world, 650, 100, "static")
  objects.cathead.body:setUserData(objects.cathead) -- TODO MIGHT PRODUCE A BUG -- not catbody, but cathead
  objects.cathead.shape = love.physics.newRectangleShape(100, 70)
  --objects.cathead.fixture = love.physics.newFixture(objects.cathead.body, objects.cathead.shape)
  --objects.cathead.fixture:setGroupIndex(NON_COLLIDE_GRP)
  objects.cathead.catjoint = love.physics.newRevoluteJoint( objects.cathead.body, objects.catbody.body, 650, 100, false )
  objects.cathead.catmaxjoint = love.physics.newRopeJoint( objects.catbody.body, objects.cathead.body, 650, 100, 650, 100, 30, false )
  objects.cathead.image = love.graphics.newImage("cat_head.png")

end

function love.update(dt)
  world:update(dt) --this puts the world into motion
  local x, y = love.mouse.getPosition()
  x = screen2world(x, tX)
  y = screen2world(y, tY)
  if (currentObj == objects.mwdoor) then
    if objects.mwdoor.open then
      objects.mwdoor.body:applyLinearImpulse(-400, 0)
      objects.mwdoor.open = false
      currentObj = nil
    else
      objects.mwdoor.body:applyLinearImpulse(400, 0)
      objects.mwdoor.open = true
      currentObj = nil
    end
  end
  -- MW controls
  if (currentObj ~= nil) then
    DEBUG = currentObj
  end
  if (currentObj == objects.mwwatts) then
    local angle = math.floor(math.abs(math.deg(objects.mwwatts.body:getAngle())) + 0.5)
    if (angle == 0 or angle == 360) then
      objects.mwwatts.body:setAngle(math.rad(90))
    elseif (angle == 90) then
      objects.mwwatts.body:setAngle(math.rad(180))
    elseif (angle == 180) then
      objects.mwwatts.body:setAngle(math.rad(270))
    elseif (angle == 270) then
      objects.mwwatts.body:setAngle(math.rad(0))
    end
    currentObj = nil
  end
  if (currentObj == objects.mwtime) then
    local angle = math.floor(math.abs(math.deg(objects.mwtime.body:getAngle())) + 0.5)
    if ((angle >= 0 and angle < 55) or angle == 360) then
      objects.mwtime.body:setAngle(math.rad(60))
    elseif (angle >= 55 and angle < 115) then
      objects.mwtime.body:setAngle(math.rad(120))
    elseif (angle >= 115 and angle < 175) then
      objects.mwtime.body:setAngle(math.rad(180))
    elseif (angle >= 175 and angle < 235) then
      objects.mwtime.body:setAngle(math.rad(240))
    elseif (angle >= 235 and angle < 295) then
      objects.mwtime.body:setAngle(math.rad(300))
    elseif ((angle >= 295 and angle < 360) or angle < 0) then
      objects.mwtime.body:setAngle(math.rad(360))
    end
    currentObj = nil
  end

  -- Drag objects
  if (currentObj == objects.catbody or currentObj == objects.cathead) then
    currentObj.body:setPosition(x, y)
  end

  updateTime(dt)
end

function updateTime(dt_in_s)
  if (objects.mwdoor.open) then
    local angle = math.abs(math.deg(objects.mwtime.body:getAngle()))
    if (angle > 0) then
      objects.mwtime.body:setAngle(math.rad(angle - DEGREE_PER_S * dt_in_s))
      updatePower(dt_in_s)
      angle = math.deg(objects.mwtime.body:getAngle())
      if (angle < 0) then
        if (DING_ONCE) then
          objects.mwbody.ding:play()
          DING_ONCE = false
        end
        blowUp()
      end
    end
  end
end

function updatePower(dt_in_s)
  local angle = math.floor(math.abs(math.deg(objects.mwwatts.body:getAngle())) + 0.5)
  local timeAngle = math.floor(math.abs(math.deg(objects.mwtime.body:getAngle())) + 0.5)
  if (timeAngle >= 1) then
    power = power + WATTS[angle] * dt_in_s
  end
end

function blowUp()
  objects.mwbody.body:setType("dynamic")
  objects.mwwatts.body:setType("dynamic")
  objects.mwtime.body:setType("dynamic")
  if (not objects.mwdoor.mwjoint:isDestroyed()) then
    objects.mwdoor.mwjoint:destroy()
  end
  objects.mwdoor.body:applyLinearImpulse(-40, -100)
  objects.mwbody.body:applyLinearImpulse(000, -80)
end

function love.mousepressed( x, y, button, istouch )
  if ((button == 1) or istouch) then
    currentObj = getObjAtMouse()
  end
end

function love.mousereleased( x, y, button, istouch )
  if ((currentObj == objects.catbody) or (currentObj == objects.cathead)) then
    currentObj = nil
  end
end

function love.draw()
  love.graphics.push("all")

  love.graphics.translate(tX, tY)
  love.graphics.scale(scaleFactor, scaleFactor)

  local b = objects.kitchen
  local bgScale = math.max(gameWidth / b.background:getWidth(), gameHeight / b.background:getHeight())
  love.graphics.draw(b.background, 0, 0, 0, bgScale, bgScale, gameWidth / b.background:getWidth(), 0)

  b = objects.mwbody
  love.graphics.draw(b.image, b.body:getX(), b.body:getY(), b.body:getAngle(), 1, 1, b.image:getWidth()/2, b.image:getHeight()/2)

  b = objects.mwwatts
  love.graphics.draw(b.image, b.body:getX(), b.body:getY(), b.body:getAngle(), 1, 1, b.image:getWidth()/2, b.image:getHeight()/2)

  b = objects.mwtime
  love.graphics.draw(b.image, b.body:getX(), b.body:getY(), b.body:getAngle(), 1, 1, b.image:getWidth()/2, b.image:getHeight()/2)

  -- Cat
  b = objects.catbody
  love.graphics.draw(b.image, b.body:getX(), b.body:getY(), b.body:getAngle(), 1, 1, b.image:getWidth()/2, b.image:getHeight()/2)
  b = objects.cathead
  love.graphics.draw(b.image, b.body:getX(), b.body:getY(), b.body:getAngle(), 1, 1, b.image:getWidth()/2, b.image:getHeight()/2)

  -- Door
  b = objects.mwdoor
  love.graphics.draw(b.image, b.body:getX(), b.body:getY(), b.body:getAngle(), 1, 1, b.image:getWidth()/2, b.image:getHeight()/2)

  -- Debug output
  love.graphics.print( "Power: "..tostring(power), 10, 0 )
  if currentObj ~= nil then
    love.graphics.print( "Obj present", 10, 20 )
  end
  local x, y = love.mouse.getPosition()
  love.graphics.print( math.deg(objects.mwwatts.body:getAngle()), 10, 40 )
  love.graphics.print( tostring(objects.mwwatts.mwjoint:isMotorEnabled()), 10, 60)
  love.graphics.print( "Mouse: ("..x..", "..y..")", 10, 80)
  love.graphics.print( "DEBUG: "..tostring(DEBUG), 10, 100)

  love.graphics.setColor(139, 69, 19, 0.0)
  love.graphics.polygon("fill", objects.kitchen.body:getWorldPoints(objects.kitchen.shape:getPoints()))

  love.graphics.setColor(0, 0, 0, 255)
  local inverseScaleFactor = 1.0 / scaleFactor
  if tX == 0 then
    love.graphics.rectangle("fill", 0, -tY * 2, gameWidth, tY * 2)
    love.graphics.rectangle("fill", 0, screen2world(tY + scaleFactor * gameHeight, tY), gameWidth, tY * 4)
  elseif tY == 0 then
    love.graphics.rectangle("fill", -tX * 2, 0, tX * 2, gameHeight)
    love.graphics.rectangle("fill", screen2world(tX + scaleFactor * gameWidth, tX), 0, tX * 4, gameHeight)
  end

  love.graphics.pop()
end

function love.resize(w, h)
  local sfX = w / gameWidth
  local sfY = h / gameHeight
  if sfX < sfY then
    scaleFactor = sfX
    tX = 0
    tY = (h - gameHeight * scaleFactor) / 2
  else
    scaleFactor = sfY
    tX = (w - gameWidth * scaleFactor) / 2
    tY = 0
  end
  screenWidth = w
  screenHeight = h
end

function getObjAtMouse()
  local x, y = love.mouse.getPosition()
  x = screen2world(x, tX)
  y = screen2world(y, tY)
  world:queryBoundingBox( x - 0.1, y - 0.1, x + 0.1, y + 0.1, getObjCB )
  return currentObj
end

function getObjCB(fixture)
  --if (fixture:getBody():getType() ~= "static") then
    local x, y = love.mouse.getPosition()
    x = screen2world(x, tX)
    y = screen2world(y, tY)
    local body = fixture:getBody()
    if (fixture:testPoint(x, y)) then
        currentObj = body:getUserData()
        if ((currentObj == objects.catbody) or (currentObj == objects.cathead)) then
          objects.catbody.body:setType("dynamic")
        end
        return false
    end
  --end
    return true
end

function screen2world(screenCoord, offset)
  return (screenCoord - offset) / scaleFactor
end
