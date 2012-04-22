gamejs = require 'gamejs'
mask = require 'gamejs/mask'
$v = require 'gamejs/utils/vectors'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
SCREEN_HALFX  = SCREEN_WIDTH/2
SCREEN_HALFY  = SCREEN_HEIGHT/2
LEVEL         = 'images/test_world.png'
HERO          = 'images/hero_mask.png'
LEVEL_WIDTH   = 2000
LEVEL_HEIGHT  = 2000


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
    constructor: (path, @position, dimensions) ->
        @originalImage = gamejs.image.load(path)

        if (typeof dimensions) == 'undefined'
            @dimensions = @originalImage.getSize()
        else
            @dimensions = dimensions

        @image = @originalImage
        @rect = new gamejs.Rect(@position, @dimensions)
        @mask = mask.fromSurface(@image)

class World extends Sprite
    constructor: (path, position) ->
        super path, position
        @angle = 0
        @direction = 0
        @dummySurface = new gamejs.Surface(@dimensions)

    update: (msDuration) ->
        if @direction != 0
            # The length of an arc is L = d_angle * radius * pi / 180°
            # We want L = 1
            d_angle = 180 / (@rect.height * Math.PI)
            @angle += d_angle * msDuration * @direction
            @image = gamejs.transform.rotate(@originalImage, @angle)
            @mask = mask.fromSurface(@image)

            # We need to resize the containing Rect so that it contains the full
            # size rotated image. (If we keep the same dimensions the image is
            # scaled). We do this by rotating a surface with the dimensions of
            # the image and using its new size
            center = @rect.center
            dimensions = gamejs.transform.rotate(@dummySurface, @angle).getSize()
            [@rect.width, @rect.height] = dimensions
            @rect.center = center

class Hero extends Sprite
    constructor: (path, position, @worldcenter) ->
        super path, position
        @step = 1
        @direction = 0
        @angle = 0

    update: (msDuration) ->
        if @direction != 0
            radius = $v.distance(@worldcenter, @rect.center)
            d_angle = 180 / (radius * Math.PI)
            @angle += d_angle * @step * @direction


            v = $v.multiply($v.subtract(@worldcenter, @rect.center), [-1,1])
            rv = $v.rotate(v, @angle)

            @rect.center = $v.add(@worldcenter, rv)



class Mask
    constructor: (surface) ->
        s = surface.surface
        @mask = mask.fromSurface(s)


main = ->
    handleInput = (msDuration) ->
        # input
        gamejs.event.get().forEach (event) ->
            for h in handlers
                h.on(event)

    simulate = (msDuration) ->
        controller.update(msDuration)
        if controller.left
            hero.direction = -1
        else if controller.right
            hero.direction = 1
        else hero.direction = 0

        for thing in things
            thing.update(msDuration)

        if(gamejs.sprite.collideMask(world, hero))
            console.log("collision")
            hero.direction *= -1
            hero.update(msDuration)

    render = (msDuration) ->
        display.clear()
        for thing in things
            thing.draw(display)

    things = []
    handlers = []

    display = gamejs.display.setMode([SCREEN_WIDTH, SCREEN_HEIGHT])

    world = new World(LEVEL, [SCREEN_HALFX - LEVEL_WIDTH/2, SCREEN_HALFY])

    things.push world

    hero = new Hero(HERO, [SCREEN_HALFX, SCREEN_HALFY - 130], world.rect.center)
    things.push hero

    controller = new KeyboardController
    handlers.push controller

    callbacks = [handleInput, simulate, render]

    for callback in callbacks
        gamejs.time.fpsCallback(callback, this, FPS)


gamejs.preload([
    LEVEL,
    HERO,
])

gamejs.ready(main)

