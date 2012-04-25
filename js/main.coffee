gamejs = require 'gamejs'
mask = require 'gamejs/mask'
$t = require 'gamejs/transform'
$v = require 'gamejs/utils/vectors'


SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
SCREEN_HALFX  = SCREEN_WIDTH/2
SCREEN_HALFY  = SCREEN_HEIGHT/2
LEVEL         = 'images/test_world.png'
HERO          = 'images/hero.png'
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

        @dummySurface = new gamejs.Surface(@dimensions)

    rotateBy: (degrees) ->
        @angle += degrees
        @image = gamejs.transform.rotate(@originalImage, @angle)

        @mask = mask.fromSurface(@image)

        # Resize the containing Rect so that it contains the full
        # size rotated image. (If we keep the same dimensions the image is
        # scaled). We do this by rotating a surface with the dimensions of
        # the image and using its new size
        center = @rect.center
        dimensions = $t.rotate(@dummySurface, @angle).getSize()
        [@rect.width, @rect.height] = dimensions
        @rect.center = center


class World extends Sprite
    constructor: (path, position) ->
        super path, position
        @angle = 0
        @direction = 0

    update: (msDuration) ->
        if @direction != 0
            # The length of an arc is L = d_angle * radius * pi / 180°
            # We want L = 1
            d_angle = 180 / (@rect.height * Math.PI) * msDuration * @direction[0]
            @rotateBy(d_angle)


class Hero extends Sprite
    constructor: (path, position, @worldcenter) ->
        super path, position
        @step = 10
        @direction = [0,0]
        @angle = 0

    update: (msDuration) ->
        #

    moveBy: (vector) ->
        u = $v.unit(vector)
        # change the coordinate system origin from the hero to the screen origin
        direction = $v.rotate(vector, u[0]  * gamejs.utils.math.radians(@angle))

        u = $v.unit(direction)

        unless (u[0] == 0 && u[1] == 0)
                @rect.center = $v.add(@rect.center, direction)

                # TODO: deal with image flipping (for left/right movement)
            
                # rotate the sprite if it's not moving in the same direction as before
                d_angle = gamejs.utils.math.degrees($v.angle(@direction, direction)) % 360

                if d_angle % 180 != 0
                    console.log d_angle
                    # FIXME: find a way to avoid rotating this often
                    #@rotateBy(u[0] * d_angle)

                @direction = direction


main = ->
    handleInput = (msDuration) ->
        gamejs.event.get().forEach (event) ->
            for h in handlers
                h.on(event)

    simulate = (msDuration) ->

        direction = [0,0]

        controller.update(msDuration)
        if controller.left
            direction = [-1, 0]
        else if controller.right
            direction = [1, 0]
        else direction = [0, 0]

        direction = $v.multiply(direction, hero.step)

        for thing in things
            thing.update(msDuration)

        hero.moveBy(direction)

        # Don't move the hero up or down by more than this if trying to adjust
        # vertical position
        d_y_treshold = 2

        # We hit something, captain. Better check it out!
        if(gamejs.sprite.collideMask(world, hero))

            # First revert to the position before the collision
            hero.moveBy($v.multiply(direction, -1))

            # The collision could be due to the hero going up on an incline. Try
            # moving the hero up a bit. If it's not enough we have an
            # unsurmountable obstacle
            
            d_y = 0
            while d_y <= d_y_treshold
                v = direction
                v[1] -= d_y * hero.step
                hero.moveBy(v) # up
                d_y++

                if(gamejs.sprite.collideMask(world, hero))
                    hero.moveBy($v.multiply(v, -1))

        # Adapt hero vertical position if he's going down on an incline
        collision = false
        d_y = 0
        until collision || d_y > d_y_treshold
            v = [0, d_y * hero.step]
            hero.moveBy(v) # down
            d_y++

            if(gamejs.sprite.collideMask(world, hero))
                collision = true
                hero.moveBy($v.multiply(v, -1))


    render = (msDuration) ->
        display.clear()
        for thing in things
            thing.draw(display)

    things = []
    handlers = []

    display = gamejs.display.setMode([SCREEN_WIDTH, SCREEN_HEIGHT])

    world = new World(LEVEL, [SCREEN_HALFX - LEVEL_WIDTH/2, SCREEN_HALFY])

    things.push world

    hero = new Hero(HERO, [SCREEN_HALFX - 100, SCREEN_HALFY - 130], world.rect.center)
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

