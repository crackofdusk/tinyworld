gamejs = require 'gamejs'
mask = require 'gamejs/mask'

SCREEN_WIDTH = 1000
SCREEN_HEIGHT = 600
SCREEN_HALFX  = SCREEN_WIDTH/2
SCREEN_HALFY  = SCREEN_HEIGHT/2
LEVEL         = 'images/test_world.png'
LEVEL_WIDTH   = 200
LEVEL_HEIGHT  = 200


FPS = 30

class Handler
    on: (event) ->
        console.log 'Got event', event

class Controller extends Handler
    update: (msDuration) ->
        # business logic here

class KeyboardController extends Controller
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
                    when gamejs.event.K_DOWN  then @down  = true

    update: (msDuration) ->


# Might be useful
class Surface
    constructor: (@display, path, @position = [0,0]) ->
        @surface = gamejs.image.load(path)

    update: (position) ->
        @position = position

    draw: ->
        @display.blit(@surface, @position)
        

class Sprite extends gamejs.sprite.Sprite
    constructor: (path, @position) ->
        @originalImage = gamejs.image.load(path)
        @angle = 0
        @direction = 0
        @image = @originalImage
        @rect = new gamejs.Rect(@position, [LEVEL_WIDTH, LEVEL_HEIGHT])

class World extends Sprite
    constructor: (path, position) ->
        super path, position

    update: (msDuration) ->
        if @direction != 0
            @angle += msDuration * 0.01 * @direction
            @image = gamejs.transform.rotate(@originalImage, @angle)

class Mask
    constructor: (surface) ->
        s = surface.surface
        @mask = mask.fromSurface(s)


main = ->
    gameTick = (msDuration) ->
        # input
        gamejs.event.get().forEach (event) ->
            for h in handlers
                h.on(event)

        # simulation
        controller.update(msDuration)
        if controller.left
            world.direction = 1
        else if controller.right
            world.direction = -1
        else world.direction = 0
        for thing in things
            thing.update(msDuration)

        # draw
        display.clear()
        for thing in things
            thing.draw(display)

    things = []
    handlers = []

    display = gamejs.display.setMode([SCREEN_WIDTH, SCREEN_HEIGHT])

    world = new World(LEVEL, [SCREEN_HALFX - LEVEL_WIDTH/2, SCREEN_HALFY])

    things.push world

    controller = new KeyboardController
    handlers.push controller

    gamejs.time.fpsCallback(gameTick, this, FPS)


gamejs.preload([
    LEVEL,
])

gamejs.ready(main)

