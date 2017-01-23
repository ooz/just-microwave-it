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
objectsInMW = {}

CATEGORY_OBJS = bit.lshift(1, 0)
CATEGORY_GROUND = bit.lshift(1, 1)
CATEGORY_MICROWAVE = bit.lshift(1, 2)
CATEGORY_MWCONTROLS = bit.lshift(1, 3)
CATEGORY_MWDUMMIES = bit.lshift(1, 4)

MASK_OBJECTS = bit.bor(CATEGORY_OBJS, CATEGORY_GROUND, CATEGORY_MWDUMMIES)
MASK_DUMMIES = CATEGORY_OBJS

GROUP_DONT_COLLIDE = bit.lshift(-1, 0)
GROUP_ALWAYS_COLLIDE = bit.lshift(1, 0)

BOOM_ONCE = true
MEOW_ONCE = true
WOBB_ONCE = true

WATTS = {}
WATTS[0] = 200
WATTS[360] = 200
WATTS[90] = 400
WATTS[180] = 600
WATTS[270] = 700

POWER_THRESHOLDS = {}
POWER_THRESHOLDS["cat"] = 800
POWER_THRESHOLDS["waste"] = 2000
POWER_THRESHOLDS["mwmini"] = 4000

EFFECT_VOLUME = 0.75

DEBUG = 0

DUMMY_WIDTH = 300
DUMMY_HEIGHT = 10

local canvas

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
  objects.kitchen.fixture = love.physics.newFixture(objects.kitchen.body, objects.kitchen.shape, 1000)
  objects.kitchen.fixture:setFilterData(CATEGORY_GROUND, CATEGORY_OBJS, GROUP_ALWAYS_COLLIDE)
  --objects.kitchen.fixture:setFriction(1.0)
  objects.kitchen.background = love.graphics.newImage("kueche.png")
  --objects.kitchen.music = love.audio.newSource("Just_Microwave_It_Titlesong.mp3")
  objects.kitchen.music = love.audio.newSource("Just_Microwave_It_Loop.mp3")
  objects.kitchen.music:setVolume(0.5)
  objects.kitchen.boom = love.audio.newSource("ggj_mwi_boom.mp3")
  objects.kitchen.boom:setVolume(1.0)

  -- Cat
  objects.catbody = {}
  objects.catbody.name = "cat"
  objects.catbody.body = love.physics.newBody(world, 600, 100, "dynamic")
  objects.catbody.body:setUserData(objects.catbody)
  objects.catbody.shape = love.physics.newRectangleShape(120, 70)
  objects.catbody.fixture = love.physics.newFixture(objects.catbody.body, objects.catbody.shape)
  objects.catbody.fixture:setFilterData(CATEGORY_OBJS, MASK_OBJECTS, 0)
  --objects.catbody.mousejoint = love.physics.newMouseJoint(objects.catbody.body, love.mouse.getPosition())
  objects.catbody.image = love.graphics.newImage("cat_body.png")
  objects.cathead = {}
  objects.cathead.name = "cat"
  objects.cathead.body = love.physics.newBody(world, 650, 100, "dynamic")
  objects.cathead.body:setUserData(objects.cathead) -- TODO MIGHT PRODUCE A BUG -- not catbody, but cathead
  objects.cathead.shape = love.physics.newRectangleShape(100, 70)
  objects.cathead.fixture = love.physics.newFixture(objects.cathead.body, objects.cathead.shape)
  objects.cathead.fixture:setFilterData(CATEGORY_OBJS, MASK_OBJECTS, 0)
  objects.cathead.catjoint = love.physics.newRevoluteJoint( objects.cathead.body, objects.catbody.body, 650, 100, false )
  objects.cathead.catmaxjoint = love.physics.newRopeJoint( objects.catbody.body, objects.cathead.body, 650, 100, 650, 100, 10, false )
  objects.cathead.image = love.graphics.newImage("cat_head.png")
  objects.cathead.meow = love.audio.newSource("ggj_mwi_cat_meow.mp3")
  objects.cathead.meow:setVolume(EFFECT_VOLUME)
  objects.cattail = {}
  objects.cattail.name = "cat"
  objects.cattail.body = love.physics.newBody(world, 545, 120, "dynamic")
  objects.cattail.body:setUserData(objects.cattail)
  objects.cattail.shape = love.physics.newRectangleShape(22, 54)
  objects.cattail.fixture = love.physics.newFixture(objects.cattail.body, objects.cattail.shape)
  objects.cattail.fixture:setFilterData(CATEGORY_OBJS, MASK_OBJECTS, 0)
  objects.cattail.catjoint = love.physics.newRevoluteJoint( objects.cattail.body, objects.catbody.body, 545, 120, false )
  objects.cattail.catmaxjoint = love.physics.newRopeJoint( objects.catbody.body, objects.cattail.body, 545, 120, 545, 120, 2, true )
  objects.cattail.image = love.graphics.newImage("cat_tail.png")
  objects.catback = {}
  objects.catback.name = "cat"
  objects.catback.body = love.physics.newBody(world, 570, 140, "dynamic")
  objects.catback.body:setUserData(objects.catback)
  objects.catback.shape = love.physics.newRectangleShape(22, 54)
  objects.catback.fixture = love.physics.newFixture(objects.catback.body, objects.catback.shape)
  objects.catback.fixture:setFilterData(CATEGORY_OBJS, MASK_OBJECTS, 0)
  objects.catback.catjoint = love.physics.newRevoluteJoint( objects.catback.body, objects.catbody.body, 570, 140, false )
  objects.catback.catmaxjoint = love.physics.newRopeJoint( objects.catbody.body, objects.catback.body, 545, 120, 545, 120, 2, true )
  objects.catback.image = love.graphics.newImage("cat_legs.png")
  objects.catfront = {}
  objects.catfront.name = "cat"
  objects.catfront.body = love.physics.newBody(world, 630, 140, "dynamic")
  objects.catfront.body:setUserData(objects.catfront)
  objects.catfront.shape = love.physics.newRectangleShape(22, 54)
  objects.catfront.fixture = love.physics.newFixture(objects.catfront.body, objects.catfront.shape)
  objects.catfront.fixture:setFilterData(CATEGORY_OBJS, MASK_OBJECTS, 0)
  objects.catfront.catjoint = love.physics.newRevoluteJoint( objects.catfront.body, objects.catbody.body, 630, 140, false )
  objects.catfront.catmaxjoint = love.physics.newRopeJoint( objects.catbody.body, objects.catfront.body, 545, 120, 545, 120, 2, true )
  objects.catfront.image = love.graphics.newImage("cat_legs.png")

  objects.waste = {}
  objects.waste.name = "waste"
  objects.waste.body = love.physics.newBody(world, 700, gameHeight - 150 - 122 / 2 - KITCHEN_HEIGHT * 2, "dynamic")
  objects.waste.body:setUserData(objects.waste)
  objects.waste.body:setMass(50)
  objects.waste.shape = love.physics.newRectangleShape(68, 122)
  objects.waste.fixture = love.physics.newFixture(objects.waste.body, objects.waste.shape, 5)
  objects.waste.fixture:setFilterData(CATEGORY_OBJS, MASK_OBJECTS, 0)
  objects.waste.image = love.graphics.newImage("nuc_waste.png")
  objects.waste.wobb = love.audio.newSource("ggj2017_jmi_atommuell_wobble.mp3")
  objects.waste.wobb:setVolume(EFFECT_VOLUME)

  objects.mwmini = {}
  objects.mwmini.name = "mwmini"
  objects.mwmini.body = love.physics.newBody(world, 700, gameHeight - 150 / 2 - KITCHEN_HEIGHT * 2, "dynamic")
  objects.mwmini.body:setUserData(objects.mwmini)
  objects.mwmini.body:setMass(10)
  objects.mwmini.shape = love.physics.newRectangleShape(200, 150)
  objects.mwmini.fixture = love.physics.newFixture(objects.mwmini.body, objects.mwmini.shape, 5)
  objects.mwmini.fixture:setFilterData(CATEGORY_OBJS, MASK_OBJECTS, 0)
  objects.mwmini.image = love.graphics.newImage("mwmini.png")

  objects.mwbody = {}
  objects.mwbody.name = "mwbody"
  objects.mwbody.body = love.physics.newBody(world, gameWidth / 2, gameHeight - KITCHEN_HEIGHT - MW_HEIGHT / 2, "static")
  objects.mwbody.body:setUserData(objects.mwbody)
  objects.mwbody.body:setMass(MW_MASS_IN_KG)
  objects.mwbody.shape = love.physics.newRectangleShape(MW_WIDTH, MW_HEIGHT)
  objects.mwbody.fixture = love.physics.newFixture(objects.mwbody.body, objects.mwbody.shape)
  objects.mwbody.fixture:setFriction(1.0)
  objects.mwbody.fixture:setFilterData(CATEGORY_MICROWAVE, CATEGORY_GROUND, 0)
  objects.mwbody.image = love.graphics.newImage("mwbody.png")
  objects.mwbody.ding = love.audio.newSource("ggj_mwi_MWping.mp3", "static")
  objects.mwbody.ding:setVolume(EFFECT_VOLUME)
  objects.mwbody.on = false

  objects.mwdummytop = {}
  objects.mwdummytop.name = "mwdummytop"
  objects.mwdummytop.body = love.physics.newBody(world, 200 + DUMMY_WIDTH / 2, 250 + DUMMY_HEIGHT / 2, "static")
  objects.mwdummytop.shape = love.physics.newRectangleShape(DUMMY_WIDTH, DUMMY_HEIGHT)
  objects.mwdummytop.fixture = love.physics.newFixture(objects.mwdummytop.body, objects.mwdummytop.shape, 1000)
  objects.mwdummytop.fixture:setFilterData(CATEGORY_MWDUMMIES, MASK_DUMMIES, 0)
  objects.mwdummyleft = {}
  objects.mwdummyleft.name = "mwdummytop"
  objects.mwdummyleft.body = love.physics.newBody(world, 200 + DUMMY_HEIGHT / 2, 250 + DUMMY_WIDTH / 2, "static")
  objects.mwdummyleft.shape = love.physics.newRectangleShape(DUMMY_HEIGHT, DUMMY_WIDTH)
  objects.mwdummyleft.fixture = love.physics.newFixture(objects.mwdummyleft.body, objects.mwdummyleft.shape, 1000)
  objects.mwdummyleft.fixture:setFilterData(CATEGORY_MWDUMMIES, MASK_DUMMIES, 0)
  objects.mwdummyright = {}
  objects.mwdummyright.name = "mwdummytop"
  objects.mwdummyright.body = love.physics.newBody(world, 200 + 300 - DUMMY_HEIGHT / 2, 250 + DUMMY_WIDTH / 2, y, "static")
  objects.mwdummyright.shape = love.physics.newRectangleShape(DUMMY_HEIGHT, DUMMY_WIDTH)
  objects.mwdummyright.fixture = love.physics.newFixture(objects.mwdummyright.body, objects.mwdummyright.shape, 1000)
  objects.mwdummyright.fixture:setFilterData(CATEGORY_MWDUMMIES, MASK_DUMMIES, 0)
  setDummiesActive(false)

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
  objects.mwdoor.slide:setVolume(EFFECT_VOLUME)
  objects.mwdoor.toopen = false
  objects.mwdoor.isOpen = true
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
  objects.reset.image = love.graphics.newImage("rewind.png")

  canvas = love.graphics.newCanvas(800, 600)

  setupShaders()
  --objects.kitchen.music:setPitch( 6 )
  objects.kitchen.music:setLooping( true )
  love.audio.play(objects.kitchen.music)

  love.resize(love.graphics.getDimensions())
end

function setupShaders()
  -- from
  -- https://love2d.org/forums/viewtopic.php?t=3733&start=270
  if love.system.getOS() == 'Android' or love.system.getOS() == 'iOS' then
    objects.shaders = {}
    objects.shaders.hole = {shader = love.graphics.newShader('hole_m.glsl')}
    objects.shaders.hole.shader:send('size',{gameWidth, gameHeight})
    objects.shaders.hole.shader:send('pos',{gameWidth / 2, gameHeight / 2})
    objects.shaders.hole.shader:send('eventH',love.window.toPixels(20))
    objects.shaders.hole.shader:send('escapeR',love.window.toPixels(20)*1.5)
    objects.shaders.hole.shader:send('holeColor',{0,0,0})
  else
    objects.shaders = {}
    objects.shaders.hole = {shader = love.graphics.newShader('hole.glsl')}
    objects.shaders.hole.shader:send('size',{gameWidth, gameHeight})
    objects.shaders.hole.shader:send('pos',{gameWidth / 2, gameHeight / 2})
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
  objects.mwdoor.isOpen = true
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

  objects.waste.body:setPosition(700, gameHeight - 150 - 122 / 2 - KITCHEN_HEIGHT)
  objects.waste.body:setAngle(0)
  objects.waste.body:setLinearVelocity(-1, -1)
  objects.waste.body:setType("dynamic")

  objects.mwmini.body:setPosition(700, gameHeight - 150 / 2 - KITCHEN_HEIGHT)
  objects.mwmini.body:setAngle(0)
  objects.mwmini.body:setLinearVelocity(-1, -1)
  objects.mwmini.body:setType("dynamic")

  setDummiesActive(false)

  currentObj = nil
  power = 0
  t = 0
  BOOM_ONCE = true
  MEOW_ONCE = true
  WOBB_ONCE = true

  success = love.window.showMessageBox( "Thanks for Playing!", "Just Microwave It!\
By Konstantin Freybe and Oliver Zscheyge", "info", true )
end

function setDummiesActive(active)
  objects.mwdummytop.body:setActive(active)
  objects.mwdummyleft.body:setActive(active)
  objects.mwdummyright.body:setActive(active)
end


-- Taken from
-- http://lua-users.org/wiki/IntegerDomain
function intlimit()
  local floor = math.floor

  -- get highest power of 2 which Lua can still handle as integer
  local step = 2
  while true do
    local nextstep = step*2
    if nextstep-(nextstep-1) == 1 and nextstep > 0 then
      step = nextstep
    else
      break
    end
  end

  -- now get the highest number which Lua can still handle as integer
  local limit,step = step,floor(step/2)
  while step > 0 do
    local nextlimit = limit+step
    if nextlimit-(nextlimit-1) == 1 and nextlimit > 0 then
      limit = nextlimit
    end
    step = floor(step/2)
  end
  return limit
end

local t = 0
local MAX_INT = intlimit()
local tMWDoorOpDone = MAX_INT
local tForMWToChange = 0.7
function love.update(dt)
  world:update(dt)
  t = t + dt

  updateMWTimer(dt)

  local x, y = love.mouse.getPosition()
  x = screen2world(x, tX)
  y = screen2world(y, tY)

  -- MW door
  if (currentObj == objects.mwdoor or currentObj == objects.mwbody) then
    tLastMWDoorOp = sumdt
    tMWDoorOpDone = t + tForMWToChange
    love.audio.play(objects.mwdoor.slide)
    if objects.mwdoor.toopen then
      objects.mwdoor.body:applyLinearImpulse(-4000, 0)
      --objects.mwdoor.toopen = false
      setDummiesActive(false)
    else
      objects.mwdoor.body:applyLinearImpulse(4000, 0)
      --objects.mwdoor.toopen = true
      setDummiesActive(true)
    end
    currentObj = nil
  end
  if objects.mwdoor.isOpen and t >= tMWDoorOpDone then
    objects.mwdoor.isOpen = false
    objects.mwdoor.toopen = true
    tMWDoorOpDone = MAX_INT
  elseif not objects.mwdoor.isOpen and t >= tMWDoorOpDone then
    objects.mwdoor.isOpen = true
    objects.mwdoor.toopen = false
    tMWDoorOpDone = MAX_INT
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
      or currentObj == objects.catfront
      or currentObj == objects.waste
      or currentObj == objects.mwmini) then
    currentObj.body:setPosition(x, y)
    if currentObj.name == "cat" then
      if MEOW_ONCE then
        objects.cathead.meow:play()
        MEOW_ONCE = false
      end
    else
      if currentObj.name == "waste" then
        objects.waste.wobb:play()
        WOBB_ONCE = false
      end
      currentObj.body:setLinearVelocity(0, 0)
    end
  end

  -- Reset
  if (currentObj == objects.reset) then
    resetObjs()
  end

  if objects.mwbody.on and objects.mwdoor.gone then
    effect:send("time", t)
  end
  --updateBlackHole(t)
end

function updateBlackHole(tAbs)
  objects.shaders.hole.shader:send("eventH", tAbs * 300)
  objects.shaders.hole.shader:send("escapeR", tAbs * 300)
  objects.shaders.hole.shader:send("size", {gameWidth, gameWidth})
  objects.shaders.hole.shader:send("pos", {gameWidth / 2, gameHeight / 2})
end

function updateMWTimer(dt_in_s)
  if (objects.mwdoor.toopen) then
    local angle = math.abs(math.deg(objects.mwtime.body:getAngle()))
    if (angle > 0) then
      objects.mwbody.on = true
      objects.mwbody.ding:stop()
      local newAngle = angle - DEGREE_PER_S * dt_in_s
      objects.mwtime.body:setAngle(math.rad(newAngle))
      newAngle = math.floor(newAngle)
      if newAngle == 0 then
        objects.mwtime.body:setAngle(0)
      end
      updatePower(dt_in_s)
      if (newAngle <= 0) then
        objects.mwbody.ding:play()
        print("ding " .. dt_in_s)
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
  --objects.mwbody.body:setType("dynamic")
  objects.mwwatts.body:setType("dynamic")
  objects.mwtime.body:setType("dynamic")
  objects.mwbody.on = false
  power = 0
  if (not objects.mwdoor.mwjoint:isDestroyed()) then
    objects.mwdoor.mwjoint:destroy()
  end
  setDummiesActive(false)
  objects.mwdoor.body:applyLinearImpulse(-4000, -30000)
  --objects.mwbody.body:applyLinearImpulse(0, -4000)
  if (BOOM_ONCE) then
    objects.kitchen.boom:play()
    BOOM_ONCE = false
  end
end

function love.mousepressed( x, y, button, istouch )
  getObjAtMouse(x, y)
end

function love.mousereleased( x, y, button, istouch )
    currentObj = nil
    MEOW_ONCE = true
    WOBB_ONCE = true
end

function love.draw()
  --love.graphics.setWireframe( true )

  love.graphics.push("all")

  love.graphics.setCanvas(canvas)

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

  -- Door (render before objects (behind) when open)
  if objects.mwdoor.isOpen then
    renderImg(objects.mwdoor)
  end

  -- Cat
  renderImg(objects.catbody)
  renderImg(objects.cattail)
  renderImg(objects.catfront)
  renderImg(objects.catback)
  renderImg(objects.cathead)

  -- Minimicrowave
  renderImg(objects.mwmini)

  -- Waste
  renderImg(objects.waste)

  -- Door (render last when closed)
  if not objects.mwdoor.isOpen or (not objects.mwdoor.toopen and objects.mwdoor.isOpen) then
    renderImg(objects.mwdoor)
  end



  -- Debug output
  --love.graphics.print( "Power: "..tostring(power), 10, 0 )
  --if currentObj ~= nil then
  --  love.graphics.print( "Obj present", 10, 20 )
  --end
  --local x, y = love.mouse.getPosition()
  --love.graphics.print( math.deg(objects.mwwatts.body:getAngle()), 10, 40 )
  --love.graphics.print( math.deg(objects.mwtime.body:getAngle()), 10, 60)
  --love.graphics.print( "Mouse: ("..x..", "..y..")", 10, 80)
  --love.graphics.print( "DEBUG: "..tostring(DEBUG), 10, 100)

  -- Ground
  --love.graphics.setColor(139, 69, 19, 255)
  --love.graphics.polygon("fill", objects.kitchen.body:getWorldPoints(objects.kitchen.shape:getPoints()))

  -- Reset "button"
  love.graphics.setCanvas()

  love.graphics.translate(tX, tY)
  love.graphics.scale(scaleFactor, scaleFactor)
  love.graphics.setBlendMode("alpha", "premultiplied")
  --love.graphics.setShader(objects.shaders.hole.shader)
  love.graphics.draw(canvas)
  love.graphics.setShader()

  renderImg(objects.reset)

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
  local x, y = love.mouse.getPosition()
  x = screen2world(x, tX)
  y = screen2world(y, tY)
  local obj = testObjs(x, y)
  if (objects.mwwatts.fixture:testPoint(x, y)) then
    currentObj = objects.mwwatts
    DEBUG = currentObj
    return false
  elseif (objects.mwtime.fixture:testPoint(x, y)) then
    currentObj = objects.mwtime
    DEBUG = currentObj
    return false
  elseif (objects.mwdoor.fixture:testPoint(x, y) and not objects.mwdoor.isOpen) then
    currentObj = objects.mwdoor
    DEBUG = currentObj
    return false
  elseif (obj) then
    currentObj = obj
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

function testObjs(x, y)
  if (testCat(x, y)) then
    return objects.cathead
  elseif (objects.waste.fixture:testPoint(x, y)) then
    return objects.waste
  elseif (objects.mwmini.fixture:testPoint(x, y)) then
    return objects.mwmini
  end
  return nil
end

function testCat(x, y)
  return objects.catbody.fixture:testPoint(x, y) or objects.cathead.fixture:testPoint(x, y) or objects.cattail.fixture:testPoint(x, y) or objects.catfront.fixture:testPoint(x, y) or objects.catback.fixture:testPoint(x, y)
end

function screen2world(screenCoord, offset)
  return (screenCoord - offset) / scaleFactor
end
