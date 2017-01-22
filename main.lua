METER_IN_PX = 100
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

CATEGORY_OBJS = bit.lshift(1, 0)
CATEGORY_GROUND = bit.lshift(1, 1)
CATEGORY_MICROWAVE = bit.lshift(1, 2)
CATEGORY_MWCONTROLS = bit.lshift(1, 3)

GROUP_DONT_COLLIDE = bit.lshift(-1, 0)
GROUP_ALWAYS_COLLIDE = bit.lshift(1, 0)

DING_ONCE = true

WATTS = {}
WATTS[0] = 200
WATTS[360] = 200
WATTS[90] = 400
WATTS[180] = 600
WATTS[270] = 700

DEBUG = 0

function love.load()
  gameWidth = 800
  gameHeight = 600
  screenWidth = gameWidth
  screenHeight = gameHeight
  tX = 0
  tY = 0
  scaleFactor = 1.0

  love.physics.setMeter(METER_IN_PX)
  world = love.physics.newWorld(0, FALLBESCHLEUNIGUNG * METER_IN_PX, true)
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)
  power = 0

  effect = love.graphics.newShader [[
      extern number time;
      vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
      {
          vec4 c = Texel(texture, texture_coords);
          return vec4((c.r + abs(sin(time)) / 2.0), c.g, c.b, 1.0);
      }
  ]]

  objects = {}

  objects.kitchen = {}
  objects.kitchen.name = "kitchenplate"
  objects.kitchen.body = love.physics.newBody(world, gameWidth / 2, gameHeight - KITCHEN_HEIGHT / 2, "static")
  objects.kitchen.body:setMass(70)
  objects.kitchen.body:setUserData(objects.kitchen)
  objects.kitchen.shape = love.physics.newRectangleShape(4 * gameWidth, KITCHEN_HEIGHT)
  objects.kitchen.fixture = love.physics.newFixture(objects.kitchen.body, objects.kitchen.shape, 5)
  objects.kitchen.fixture:setFilterData(CATEGORY_GROUND, CATEGORY_OBJS, GROUP_ALWAYS_COLLIDE)
  --objects.kitchen.fixture:setFriction(1.0)
  objects.kitchen.background = love.graphics.newImage("kueche.png")
  --objects.kitchen.music = love.audio.newSource("Just_Microwave_It_Titlesong.mp3")
  objects.kitchen.music = love.audio.newSource("Just_Microwave_It_Loop.mp3")
  objects.kitchen.music:setVolume(1.0)

  -- Cat
  objects.catbody = {}
  objects.catbody.name = "cat"
  objects.catbody.body = love.physics.newBody(world, 600, 100, "dynamic")
  objects.catbody.body:setUserData(objects.catbody)
  objects.catbody.shape = love.physics.newRectangleShape(120, 70)
  objects.catbody.fixture = love.physics.newFixture(objects.catbody.body, objects.catbody.shape)
  objects.catbody.fixture:setFilterData(CATEGORY_OBJS, CATEGORY_OBJS, GROUP_DONT_COLLIDE)
  objects.catbody.mousejoint = love.physics.newMouseJoint(objects.catbody.body, love.mouse.getPosition())
  objects.catbody.image = love.graphics.newImage("cat_body.png")
  objects.cathead = {}
  objects.cathead.name = "cat"
  objects.cathead.body = love.physics.newBody(world, 650, 100, "dynamic")
  objects.cathead.body:setUserData(objects.cathead) -- TODO MIGHT PRODUCE A BUG -- not catbody, but cathead
  objects.cathead.shape = love.physics.newRectangleShape(100, 70)
  objects.cathead.fixture = love.physics.newFixture(objects.cathead.body, objects.cathead.shape)
  objects.cathead.catjoint = love.physics.newRevoluteJoint( objects.cathead.body, objects.catbody.body, 650, 100, false )
  objects.cathead.mousejoint = love.physics.newMouseJoint( objects.cathead.body, love.mouse.getPosition())
  objects.cathead.catmaxjoint = love.physics.newRopeJoint( objects.catbody.body, objects.cathead.body, 650, 100, 650, 100, 10, false )
  objects.cathead.image = love.graphics.newImage("cat_head.png")
  objects.cattail = {}
  objects.cattail.name = "cat"
  objects.cattail.body = love.physics.newBody(world, 545, 120, "dynamic")
  objects.cattail.body:setUserData(objects.cattail)
  objects.cattail.shape = love.physics.newRectangleShape(22, 54)
  objects.cattail.fixture = love.physics.newFixture(objects.cattail.body, objects.cattail.shape)
  objects.cattail.catjoint = love.physics.newRevoluteJoint( objects.cattail.body, objects.catbody.body, 545, 120, false )
  objects.cattail.catmaxjoint = love.physics.newRopeJoint( objects.catbody.body, objects.cattail.body, 545, 120, 545, 120, 2, true )
  objects.cattail.image = love.graphics.newImage("cat_tail.png")
  objects.catback = {}
  objects.catback.name = "cat"
  objects.catback.body = love.physics.newBody(world, 570, 140, "dynamic")
  objects.catback.body:setUserData(objects.catback)
  objects.catback.shape = love.physics.newRectangleShape(22, 54)
  objects.catback.fixture = love.physics.newFixture(objects.catback.body, objects.catback.shape)
  objects.catback.catjoint = love.physics.newRevoluteJoint( objects.catback.body, objects.catbody.body, 570, 140, false )
  objects.catback.catmaxjoint = love.physics.newRopeJoint( objects.catbody.body, objects.catback.body, 545, 120, 545, 120, 2, true )
  objects.catback.image = love.graphics.newImage("cat_legs.png")
  objects.catfront = {}
  objects.catfront.name = "cat"
  objects.catfront.body = love.physics.newBody(world, 630, 140, "dynamic")
  objects.catfront.body:setUserData(objects.catfront)
  objects.catfront.shape = love.physics.newRectangleShape(22, 54)
  objects.catfront.fixture = love.physics.newFixture(objects.catfront.body, objects.catfront.shape)
  objects.catfront.catjoint = love.physics.newRevoluteJoint( objects.catfront.body, objects.catbody.body, 630, 140, false )
  objects.catfront.catmaxjoint = love.physics.newRopeJoint( objects.catbody.body, objects.catfront.body, 545, 120, 545, 120, 2, true )
  objects.catfront.image = love.graphics.newImage("cat_legs.png")

  objects.waste = {}
  objects.waste.name = "waste"
  objects.waste.body = love.physics.newBody(world, 700, gameHeight - 122 / 2 - KITCHEN_HEIGHT * 2, "dynamic")
  objects.waste.body:setUserData(objects.waste)
  objects.waste.body:setMass(50)
  objects.waste.shape = love.physics.newRectangleShape(68, 122)
  objects.waste.fixture = love.physics.newFixture(objects.waste.body, objects.waste.shape, 5)
  objects.waste.fixture:setFilterData(CATEGORY_OBJS, bit.bor(CATEGORY_GROUND, CATEGORY_MICROWAVE), 0)
  objects.waste.image = love.graphics.newImage("nuc_waste.png")

  objects.mwbody = {}
  objects.mwbody.name = "mwbody"
  objects.mwbody.body = love.physics.newBody(world, gameWidth / 2, gameHeight - KITCHEN_HEIGHT - MW_HEIGHT / 2, "static")
  objects.mwbody.body:setUserData(objects.mwbody)
  objects.mwbody.body:setMass(MW_MASS_IN_KG)
  objects.mwbody.shape = love.physics.newRectangleShape(MW_WIDTH, MW_HEIGHT)
  objects.mwbody.fixture = love.physics.newFixture(objects.mwbody.body, objects.mwbody.shape)
  objects.mwbody.fixture:setFriction(1.0)
  objects.mwbody.fixture:setFilterData(CATEGORY_MICROWAVE, CATEGORY_OBJS, 0)
  --objects.mwbody.fixture:setCategory(MW_CATEGORY)
  --objects.mwbody.fixture:setGroupIndex(NON_COLLIDE_GRP)
  objects.mwbody.image = love.graphics.newImage("mwbody.png")
  objects.mwbody.ding = love.audio.newSource("ggj_mwi_MWping.mp3", "static")
  objects.mwbody.ding:setVolume(1.0)
  objects.mwbody.on = false

  objects.mwdoor = {}
  objects.mwdoor.name = "mwdoor"
  objects.mwdoor.body = love.physics.newBody(world, (gameWidth - 100) / 2, gameHeight - KITCHEN_HEIGHT - MW_HEIGHT / 2, "dynamic")
  objects.mwdoor.body:setMass(MW_DOOR_MASS_IN_KG)
  objects.mwdoor.body:setUserData(objects.mwdoor)
  objects.mwdoor.shape = love.physics.newRectangleShape(300, 300)
  objects.mwdoor.fixture = love.physics.newFixture(objects.mwdoor.body, objects.mwdoor.shape)
  objects.mwdoor.fixture:setFriction(0.01)
  objects.mwdoor.fixture:setFilterData(bit.bor(CATEGORY_MICROWAVE, CATEGORY_MWCONTROLS), 0, 0)
  local x, y = objects.mwbody.body:getWorldCenter()
  objects.mwdoor.mwjoint = love.physics.newPrismaticJoint( objects.mwbody.body, objects.mwdoor.body, x, y, 1, 0, false )
  objects.mwdoor.mwjoint:setLimitsEnabled(true)
  objects.mwdoor.mwjoint:setLimits( -288, -2 )
  --objects.mwdoor.mwmaxjoint = love.physics.newRopeJoint( objects.mwbody.body, objects.mwdoor.body, x, y, x, y, 300, false )
  objects.mwdoor.image = love.graphics.newImage("mwdoor.png")
  objects.mwdoor.body:applyLinearImpulse(-4000, 0)
  objects.mwdoor.slide = love.audio.newSource("ggj_mwi_tuerauf_2.mp3", "static")
  objects.mwdoor.slide:setVolume(1.0)
  objects.mwdoor.toopen = false
  objects.mwdoor.gone = false

  x, y = love.mouse.getPosition()
  x = screen2world(x, tX)
  y = screen2world(y, tY)
  objects.mwwatts = {}
  objects.mwwatts.name = "mwwatts"
  objects.mwwatts.body = love.physics.newBody(world, gameWidth - 200 - 100 / 2, gameHeight - KITCHEN_HEIGHT - 300 + 50, "static")
  objects.mwwatts.body:setUserData(objects.mwwatts)
  objects.mwwatts.body:setAngle(0)
  objects.mwwatts.body:setLinearVelocity(0, 0)
  objects.mwwatts.shape = love.physics.newCircleShape(KNOBS_SIZE)
  objects.mwwatts.fixture = love.physics.newFixture(objects.mwwatts.body, objects.mwwatts.shape, 1)
  objects.mwwatts.fixture:setFriction(0.5)
  objects.mwwatts.fixture:setFilterData(bit.bor(CATEGORY_MICROWAVE, CATEGORY_MWCONTROLS), 0, 0)
  objects.mwwatts.mwjoint = love.physics.newRevoluteJoint( objects.mwbody.body, objects.mwwatts.body, gameWidth - 200 - 100 / 2, gameHeight - KITCHEN_HEIGHT - 300 + 50, false )
  objects.mwwatts.mousejoint = love.physics.newMouseJoint(objects.mwwatts.body, x, y)
  objects.mwwatts.image = love.graphics.newImage("mwknob.png")

  objects.mwtime = {}
  objects.mwtime.name = "mwtime"
  objects.mwtime.body = love.physics.newBody(world, gameWidth - 200 - 100 / 2, gameHeight - KITCHEN_HEIGHT - 300 + 150, "static")
  objects.mwtime.body:setUserData(objects.mwtime)
  objects.mwtime.body:setAngle(0)
  objects.mwtime.body:setLinearVelocity(0, 0)
  objects.mwtime.shape = love.physics.newCircleShape(KNOBS_SIZE)
  objects.mwtime.fixture = love.physics.newFixture(objects.mwtime.body, objects.mwtime.shape, 1)
  objects.mwtime.fixture:setFriction(0.5)
  objects.mwtime.fixture:setFilterData(bit.bor(CATEGORY_MICROWAVE, CATEGORY_MWCONTROLS), 0, 0)
  objects.mwtime.mwjoint = love.physics.newRevoluteJoint( objects.mwbody.body, objects.mwtime.body, gameWidth - 200 - 100 / 2, gameHeight - KITCHEN_HEIGHT - 300 + 150, false )
  objects.mwtime.mousejoint = love.physics.newMouseJoint(objects.mwtime.body, x, y)
  objects.mwtime.image = objects.mwwatts.image--love.graphics.newImage("mwknob.png")

  objects.reset = {}
  objects.reset.name = "resetButton"
  objects.reset.body = love.physics.newBody(world, 16, 16, "static")
  objects.reset.body:setUserData(objects.reset)
  objects.reset.shape = love.physics.newRectangleShape(32, 32)
  objects.reset.fixture = love.physics.newFixture(objects.reset.body, objects.reset.shape)

  setupShaders()
  --objects.kitchen.music:setPitch( 6 )
  objects.kitchen.music:setLooping( true )
  --love.audio.play(objects.kitchen.music)

  love.resize(love.graphics.getDimensions())
end

function beginContact(f1, f2, con)
  local f1body = f1:getBody()
  local f2body = f2:getBody()
  local f1obj = {name = "f1"}
  local f2obj = {name = "f2"}
  if f1body then f1obj = f1body:getUserData() or {name = "f1"} end
  if f2body then f2obj = f2body:getUserData() or {name = "f2"} end
  print(f1obj.name .. " beginVS ".. f2obj.name)
  --con:resetFriction()
end
function endContact(f1, f2, con)
  local f1body = f1:getBody()
  local f2body = f2:getBody()
  local f1obj = {name = "nil"}
  local f2obj = {name = "nil"}
  if f1body then f1obj = f1body:getUserData() or {name = "nil"} end
  if f2body then f2obj = f2body:getUserData() or {name = "nil"} end
  print(f1obj.name .. " endVS ".. f2obj.name)
  --con:resetFriction()
end
function preSolve(f1, f2, con)
  local f1body = f1:getBody()
  local f2body = f2:getBody()
  local f1obj = {name = "nil"}
  local f2obj = {name = "nil"}
  if f1body then f1obj = f1body:getUserData() or {name = "nil"} end
  if f2body then f2obj = f2body:getUserData() or {name = "nil"} end
  --print(f1obj.name .. " preVS ".. f2obj.name)
  --con:resetFriction()
end
function postSolve(f1, f2, con, normalImpulse, tangentImpulse)
  local f1body = f1:getBody()
  local f2body = f2:getBody()
  local f1obj = {name = "nil"}
  local f2obj = {name = "nil"}
  if f1body then f1obj = f1body:getUserData() or {name = "nil"} end
  if f2body then f2obj = f2body:getUserData() or {name = "nil"} end
  --print(f1obj.name .. " postVS ".. f2obj.name)
  --con:resetFriction()
end

function setupShaders()
  -- from
  -- https://love2d.org/forums/viewtopic.php?t=3733&start=270
  if love.system.getOS() == 'Android' or love.system.getOS() == 'iOS' then
    objects.shaders = {}
    objects.shaders.hole = {shader = love.graphics.newShader('hole_m.glsl')}
    objects.shaders.hole.shader:send('size',{gameWidth,gameHeight})
    objects.shaders.hole.shader:send('pos',{100,100})
    objects.shaders.hole.shader:send('eventH',love.window.toPixels(20))
    objects.shaders.hole.shader:send('escapeR',love.window.toPixels(20)*1.5)
    objects.shaders.hole.shader:send('holeColor',{0,0,0})
  else
    objects.shaders = {}
    objects.shaders.hole = {shader = love.graphics.newShader('hole.glsl')}
    objects.shaders.hole.shader:send('size',{gameWidth,gameHeight})
    objects.shaders.hole.shader:send('pos',{100,100})
    objects.shaders.hole.shader:send('eventH',400)
    objects.shaders.hole.shader:send('escapeR',400*1.5)
    objects.shaders.hole.shader:send('holeColor',{0,0,0})
  end
end

function resetObjs()
  objects.mwbody.body:setPosition(gameWidth / 2, gameHeight - MW_HEIGHT / 2 - KITCHEN_HEIGHT)
  objects.mwbody.body:setLinearVelocity(0, 0)
  objects.mwbody.body:setAngle( 0 )
  objects.mwbody.body:setType("static")
  objects.mwbody.on = false
  objects.mwdoor.gone = true
  objects.mwwatts.body:setPosition(gameWidth - 200 - 100 / 2, gameHeight - KITCHEN_HEIGHT - 300 + 50)
  objects.mwwatts.body:setAngle(0)
  objects.mwwatts.body:setLinearVelocity(0, 0)
  objects.mwwatts.body:setType("static")
  objects.mwtime.body:setPosition(gameWidth - 200 - 100 / 2, gameHeight - KITCHEN_HEIGHT - 300 + 150)
  objects.mwtime.body:setAngle(0)
  objects.mwtime.body:setLinearVelocity(0, 0)
  objects.mwtime.body:setType("static")

  objects.catbody.body:setPosition(600, 100)
  objects.catbody.body:setLinearVelocity(0, 0)
  objects.catbody.body:setType("dynamic")

  objects.waste.body:setPosition(700, gameHeight - 122 / 2 - KITCHEN_HEIGHT)
  objects.waste.body:setAngle(0)
  objects.waste.body:setLinearVelocity(-1, -1)
  objects.waste.body:setType("dynamic")

  currentObj = nil
  power = 0
  t = 0
  DING_ONCE = true

  success = love.window.showMessageBox( "Thanks", "Just Microwave It!\
By Konstantin Freybe and Oliver Zscheyge", "info", true )
end

local t = 0
function love.update(dt)
  world:update(dt)

  local x, y = love.mouse.getPosition()
  x = screen2world(x, tX)
  y = screen2world(y, tY)

  -- MW door
  if (currentObj == objects.mwdoor or currentObj == objects.mwbody) then
    if objects.mwdoor.toopen then
      love.audio.play(objects.mwdoor.slide)
      objects.mwdoor.body:applyLinearImpulse(-4000, 0)
      objects.mwdoor.toopen = false
      currentObj = nil
    else
      love.audio.play(objects.mwdoor.slide)
      objects.mwdoor.body:applyLinearImpulse(4000, 0)
      objects.mwdoor.toopen = true
      currentObj = nil
    end
  end
  -- MW controls
  objects.mwwatts.mousejoint:setTarget(x, y)
  objects.mwtime.mousejoint:setTarget(x, y)
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
    objects.mwwatts.body:setLinearVelocity(0, 0)
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
      objects.mwtime.body:setAngle(math.rad(0))
    end
    objects.mwtime.body:setLinearVelocity(0, 0)
    currentObj = nil
  end

  -- Drag objects
  if (currentObj == objects.catbody
      or currentObj == objects.cathead
      or currentObj == objects.cattail
      or currentObj == objects.catback
      or currentObj == objects.catfront) then
    currentObj.body:setPosition(x, y)
    currentObj.body:setLinearVelocity(0, 0)
  end
  if (currentObj == objects.waste) then
    currentObj.body:setPosition(x, y)
    currentObj.body:setLinearVelocity(0, 0)
  end

  -- Reset
  if (currentObj == objects.reset) then
    resetObjs()
  end
  updateTime(dt)
  if objects.mwbody.on and objects.mwdoor.gone then
    t = t + dt
    effect:send("time", t)
  end

end

function updateTime(dt_in_s)
  if (objects.mwdoor.toopen) then
    local angle = math.abs(math.deg(objects.mwtime.body:getAngle()))
    if (angle > 0) then
      objects.mwbody.on = true
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
    local watts_for_angle = WATTS[angle] or 0
    power = power + watts_for_angle * dt_in_s
  end
end

function blowUp()
  objects.mwbody.body:setType("dynamic")
  objects.mwwatts.body:setType("dynamic")
  objects.mwtime.body:setType("dynamic")
  objects.mwbody.on = false
  power = 0
  if (not objects.mwdoor.mwjoint:isDestroyed()) then
    objects.mwdoor.mwjoint:destroy()
  end
  objects.mwdoor.body:applyLinearImpulse(-400, -1000)
  objects.mwbody.body:applyLinearImpulse(0, -4000)
end

function love.mousepressed( x, y, button, istouch )
  getObjAtMouse(x, y)
end

function love.mousereleased( x, y, button, istouch )
    currentObj = nil
end

function love.draw()
  --love.graphics.setWireframe( true )

  love.graphics.push("all")

  --love.graphics.setShader(objects.shaders.hole.shader)

  love.graphics.translate(tX, tY)
  love.graphics.scale(scaleFactor, scaleFactor)

  local b = objects.kitchen
  local bgScale = math.max(gameWidth / b.background:getWidth(), gameHeight / b.background:getHeight())
  if (objects.mwbody.on and objects.mwdoor.gone) then
    love.graphics.setShader(effect)
  end
  love.graphics.draw(b.background, 0, 0, 0, bgScale, bgScale, gameWidth / b.background:getWidth(), 0)
  love.graphics.setShader()

  renderImg(objects.mwbody)
  renderImg(objects.mwwatts)
  renderImg(objects.mwtime)

  -- Cat
  renderImg(objects.catbody)
  renderImg(objects.cattail)
  renderImg(objects.catfront)
  renderImg(objects.catback)
  renderImg(objects.cathead)

  -- Waste
  renderImg(objects.waste)

  -- Door
  renderImg(objects.mwdoor)

  -- Debug output
  love.graphics.print( "Power: "..tostring(power), 10, 0 )
  if currentObj ~= nil then
    love.graphics.print( "Obj present", 10, 20 )
  end
  local x, y = love.mouse.getPosition()
  love.graphics.print( math.deg(objects.mwwatts.body:getAngle()), 10, 40 )
  love.graphics.print( math.deg(objects.mwtime.body:getAngle()), 10, 60)
  love.graphics.print( "Mouse: ("..x..", "..y..")", 10, 80)
  love.graphics.print( "DEBUG: "..tostring(DEBUG), 10, 100)

  -- Ground
  --love.graphics.setColor(139, 69, 19, 255)
  --love.graphics.polygon("fill", objects.kitchen.body:getWorldPoints(objects.kitchen.shape:getPoints()))

  -- Letterboxes
  love.graphics.setColor(0, 0, 0, 255)
  local inverseScaleFactor = 1.0 / scaleFactor
  if tX == 0 then
    love.graphics.rectangle("fill", 0, -tY * 2, gameWidth, tY * 2)
    love.graphics.rectangle("fill", 0, screen2world(tY + scaleFactor * gameHeight, tY), gameWidth, tY * 4)
  elseif tY == 0 then
    love.graphics.rectangle("fill", -tX * 2, 0, tX * 2, gameHeight)
    love.graphics.rectangle("fill", screen2world(tX + scaleFactor * gameWidth, tX), 0, tX * 4, gameHeight)
  end

  local touches = love.touch.getTouches()

  for i, id in ipairs(touches) do
      local x, y = love.touch.getPosition(id)
      love.graphics.setColor(255, 0, 0, 255)
      love.graphics.circle("fill", screen2world(x, tX), screen2world(y, tY), 20)
  end

  -- Reset "button"
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.polygon("fill", objects.reset.body:getWorldPoints(objects.reset.shape:getPoints()))

  love.graphics.pop()
end

function renderImg(obj)
  love.graphics.draw(obj.image, obj.body:getX(), obj.body:getY(), obj.body:getAngle(), 1, 1, obj.image:getWidth()/2, obj.image:getHeight()/2)
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

function getObjAtMouse(x, y)
  x = screen2world(x, tX)
  y = screen2world(y, tY)
  world:queryBoundingBox( x - 0.01, y - 0.01, x + 0.01, y + 0.01, getObjCB )
end

function getObjCB(fixture)
  local body = fixture:getBody()
  if body:getType() == "dynamic" then
    print("dynamic obj")
  elseif body:getType() == "static" then
    print("static obj")
  end
  local x, y = love.mouse.getPosition()
  x = screen2world(x, tX)
  y = screen2world(y, tY)
  if (objects.mwwatts.fixture:testPoint(x, y)) then
    currentObj = objects.mwwatts
    DEBUG = currentObj
    return false
  elseif (objects.mwtime.fixture:testPoint(x, y)) then
    currentObj = objects.mwtime
    DEBUG = currentObj
    return false
  elseif (testCat(x, y)) then
    currentObj = objects.cathead
    DEBUG = currentObj
    return false
  elseif (fixture:testPoint(x, y)) then
      currentObj = body:getUserData()
      DEBUG = currentObj
      return false
  end
  currentObj = nil
  return true
end

function testCat(x, y)
  return objects.catbody.fixture:testPoint(x, y) or objects.cathead.fixture:testPoint(x, y) or objects.cattail.fixture:testPoint(x, y) or objects.catfront.fixture:testPoint(x, y) or objects.catback.fixture:testPoint(x, y)
end

function screen2world(screenCoord, offset)
  return (screenCoord - offset) / scaleFactor
end
