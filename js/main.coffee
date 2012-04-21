gamejs = require 'gamejs'

# Note: this is a copy of
# https://github.com/ofmlabs/Music-Hackday-Amsterdam/blob/master/game/js/main.coffee
#
# The game mechanics are different but the structure is sane and I'm lazy to
# clean it up for the initial import.


SCREEN_WIDTH = 800
SCREEN_HEIGHT = 500
SCALE_FACTOR = 40
FPS = 30
INVERSE_FPS = 1 / FPS

class Handler
    on: (event) ->
        console.log 'Got event', event

class Controller extends Handler
    update: (msDuration) ->
        # business logic here

class MouseController extends Controller
    this.MIN_RADIUS = 0
    this.MAX_RADIUS = 1

    constructor: ->
        @first = true
        @left = false
        @right = false
        @up = false
        @down = false

    on: (event) ->
        switch event.type
            when gamejs.event.KEY_UP
                switch event.key
                    when gamejs.event.K_RIGHT then @right = false
                    when gamejs.event.K_LEFT  then @left  = false
                    when gamejs.event.K_UP    then @up    = false
                    when gamejs.event.K_DOWN  then @down  = false
            when gamejs.event.KEY_DOWN
                switch event.key
                    when gamejs.event.K_RIGHT then @right = true
                    when gamejs.event.K_LEFT  then @left  = true
                    when gamejs.event.K_UP    then @up    = true
                    #when gamejs.event.K_DOWN  then @down  = true

    update: (msDuration, hero) ->
        if @left
            force = new b2Vec2(-1, 0)
            hero.body.ApplyImpulse(force, hero.body.m_position)
        if @right
            force = new b2Vec2(1, 0)
            hero.body.ApplyImpulse(force, hero.body.m_position)
        if @up
            force = new b2Vec2(0, -10)
            hero.body.ApplyImpulse(force, hero.body.m_position)
            @up = false

class Screen
    constructor: (@display) ->

    circle: (color, x, y, radius, lineWidth) ->
        gamejs.draw.circle(@display, @color, [@scale(x), @scale(y)], @scale(radius), lineWidth)

    rect: (color, x, y, width, height, lineWidth) ->
        rect = new gamejs.Rect(@scale(x - width / 2), @scale(y - height / 2), @scale(width), @scale(height))
        gamejs.draw.rect(@display, color, rect, lineWidth)

    scale: (number) ->
        number * SCALE_FACTOR

class Thing
    update: (msDuration) ->
        # business logic here

    draw: (screen) ->
        # draw your stuff here

class Ball extends Thing
    constructor: (world, center) ->
        @color = 'rgb(128, 128, 128)'

        @circleSd = new b2CircleDef()
        @circleSd.density = 0.8
        @circleSd.radius = 0.5
        @circleSd.restitution = 0.8
        @circleSd.friction = 0.3

        @circleBd = new b2BodyDef()
        @circleBd.AddShape(@circleSd)
        @circleBd.position.Set(center[0], center[1])
        @body = world.CreateBody(@circleBd)

    radius: ->
        @circleSd.radius

    draw: (screen) ->
        lineWidth = 0 # 0 = fill
        screen.circle(@color, @body.m_position.x, @body.m_position.y, @radius(), lineWidth)

class Obstacle extends Thing
    constructor: (world, center) ->
        @color = 'rgb(15, 255, 120)'
        @width = 40 / SCALE_FACTOR
        @height = 40 / SCALE_FACTOR
        @rect = new gamejs.Rect(center[0], center[1], @width, @height)

        @shapedef = new b2BoxDef()
        #@shapedef.density = 1.0
        @shapedef.extents.Set(@rect.width / 2, @rect.height / 2)
        @shapedef.restitution = 0.4

        @bodydef = new b2BodyDef()
        @bodydef.AddShape(@shapedef)
        @bodydef.position.Set(@rect.x, @rect.y)
        @body = world.CreateBody(@bodydef)

    center: ->
        [@body.m_position.x, @body.m_position.y]

    radius: ->
        @circleSd.radius

    draw: (screen) ->
        lineWidth = 0 # 0 = fill
        screen.rect(@color, @body.m_position.x, @body.m_position.y, @width, @height, lineWidth)

    update: (msDuration) ->
        #@body.ApplyImpulse(new b2Vec2(-2.0, 0), @body.m_position)


class Ground extends Thing
    constructor: (world, @x, @y, @width, @height) ->
        @color = '#d28'

        @rect = new gamejs.Rect(@x, @y, @width, @height)
        @groundSd = new b2BoxDef()
        @groundSd.extents.Set(@rect.width / 2, @rect.height / 2)
        @groundSd.restitution = 0.8
        @groundBd = new b2BodyDef()
        @groundBd.AddShape(@groundSd)
        @groundBd.position.Set(@rect.x, @rect.y)
        @body = world.CreateBody(@groundBd)

    center: ->
        [@body.m_position.x, @body.m_position.y]

    draw: (screen) ->
        lineWidth = 0 # 0 = fill
        screen.rect(@color, @body.m_position.x, @body.m_position.y, @width, @height, lineWidth)
    
class BaseGround extends Ground
    constructor: (world, @x, @y, @radius) ->
        @color = '#2a2'
        #@rect = new gamejs.Rect(@x, @y, @width, @height)
        @groundSd = new b2CircleDef()
        #@groundSd.extents.Set(@rect.width / 2, @rect.height / 2)
        @groundSd.restitution = 0.8
        @groundSd.radius = @radius
        @groundBd = new b2BodyDef()
        @groundBd.AddShape(@groundSd)
        @groundBd.position.Set(@x, @y)
        @body = world.CreateBody(@groundBd)

    draw: (screen) ->
       lineWidth = 0 # 0 = fill
       screen.circle(@color, @body.m_position.x, @body.m_position.y, @radius, lineWidth)
 

main = ->
    gameTick = (msDuration) ->
        # input
        gamejs.event.get().forEach (event) ->
            for h in handlers
                h.on(event)

        # simulation
        controller.update(msDuration, hero)
        for thing in things
            thing.update(msDuration)
        world.Step(INVERSE_FPS / 2, 2)

        # draw
        display.clear()
        for thing in things
            thing.draw(screen)

    things = []
    handlers = []

    worldAABB = new b2AABB()
    worldAABB.minVertex.Set(-1000, -1000)
    worldAABB.maxVertex.Set( 1000,  1000)
    gravity = new b2Vec2(0, 50)
    doSleep = false
    world = new b2World(worldAABB, gravity, doSleep)

    display = gamejs.display.setMode([SCREEN_WIDTH, SCREEN_HEIGHT])
    screen = new Screen(display)

    hero = new Ball(world, [4.8, 6])
    things.push hero

    for i in [0..24]
        pos = [(0 + i * 40) / SCALE_FACTOR, ((Math.sin(i / 3 * 6.22) + 1.0) * 400) / SCALE_FACTOR]
        things.push new Obstacle(world, pos)

    halfX  = SCREEN_WIDTH / 2 / SCALE_FACTOR
    halfY  = SCREEN_HEIGHT / 2 / SCALE_FACTOR
    width  = SCREEN_WIDTH / SCALE_FACTOR
    height = SCREEN_HEIGHT / SCALE_FACTOR

    #down things.push new Ground(world, halfX, (SCREEN_HEIGHT - 20) / SCALE_FACTOR, width, 40 / SCALE_FACTOR)
    #up things.push new Ground(world, halfX, 20 / SCALE_FACTOR, width, 40 / SCALE_FACTOR)

    #left: things.push new Ground(world, 20 / SCALE_FACTOR, halfY, 40 / SCALE_FACTOR, height)
    #right: things.push new Ground(world, width - 20 / SCALE_FACTOR, halfY, 40 / SCALE_FACTOR, height)
    things.push new BaseGround(world, halfX, height+halfY*2, 16)

    controller = new MouseController
    handlers.push controller

    gamejs.time.fpsCallback(gameTick, this, FPS)

gamejs.ready(main)

