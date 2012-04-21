gamejs = require 'gamejs'
mask = require 'gamejs/mask'

SCREEN_WIDTH = 1000
SCREEN_HEIGHT = 600
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
    constructor: (path, @position = [0,0]) ->
        @originalImage = gamejs.image.load(path)
        @angle = 0
        @image = @originalImage
        @rect = new gamejs.Rect(@position)

class World extends Sprite
    constructor: (path, position) ->
        super path, position

    update: (msDuration) ->
        # FIXME: exapmle, don't hardcode this here
        direction = 1 # positive
        @angle += msDuration * 0.002 * direction
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
        for thing in things
            thing.update(msDuration)

        # draw
        display.clear()
        for thing in things
            thing.draw(display)

    things = []
    handlers = []

    display = gamejs.display.setMode([SCREEN_WIDTH, SCREEN_HEIGHT])

    world = new World('images/test_world.png')

    things.push world

    controller = new KeyboardController
    handlers.push controller

    gamejs.time.fpsCallback(gameTick, this, FPS)


gamejs.preload([
    'images/test_world.png',
])

gamejs.ready(main)

