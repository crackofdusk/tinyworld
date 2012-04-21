gamejs = require 'gamejs'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 500
SCALE_FACTOR = 40
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

    update: (msDuration, hero) ->

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

class Ground extends Thing
    

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

        # draw
        display.clear()
        for thing in things
            thing.draw(screen)

    things = []
    handlers = []

    display = gamejs.display.setMode([SCREEN_WIDTH, SCREEN_HEIGHT])
    screen = new Screen(display)

    hero = new Thing
    things.push hero

    controller = new KeyboardController
    handlers.push controller

    gamejs.time.fpsCallback(gameTick, this, FPS)

gamejs.ready(main)

