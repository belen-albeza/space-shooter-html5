PlayScene =
  preload: ->
    game.load.image 'background', 'images/background.png'
    game.load.image 'ship', 'images/captain.png'
    game.load.image 'bullet', 'images/laser.png'
    game.load.spritesheet 'alien', 'images/alien.png', 48, 42
    game.load.spritesheet 'explosion', 'images/explosion.png', 50, 50

  create: ->
    # create sprites
    game.add.sprite 0, 0, 'background'
    @aliens = game.add.group()
    @bullets = game.add.group()
    @explosions = game.add.group()
    @hero = game.add.existing new Hero

    # setup input
    @kbCursors = game.input.keyboard.createCursorKeys()
    kbSpace = game.input.keyboard.addKey Phaser.Keyboard.SPACEBAR
    kbSpace.onDown.add @_shoot, @

  update: ->
    @_handleInput()

    # spawn aliens
    @_spawnAlien() if (game.rnd.integerInRange 0, 100) < 10

    # handle collisions
    game.physics.collide @bullets, @aliens, (bullet, alien) =>
      @_spawnExplosionAt alien.x, alien.y
      bullet.kill()
      alien.kill()

  _spawnSprite: (group, klass, x, y) ->
    # try to reuse an available sprite slot in the group
    instance = group.getFirstExists false
    if instance?
      instance.reset x, y
      instance.init() if instance.init?
    # if there isn't any free slot, then add a new one
    else
      group.add new klass x, y

  _shoot: ->
    @_spawnSprite @bullets, Bullet, @hero.x, @hero.y - 20

  _spawnAlien: ->
    @_spawnSprite @aliens, Alien, game.world.randomX, -20

  _spawnExplosionAt: (x, y) ->
    @_spawnSprite @explosions, Explosion, x, y
    # @explosions.add new Explosion x, y

  _handleInput: ->
    if @kbCursors.left.isDown
      @hero.move 'left'
    else if @kbCursors.right.isDown
      @hero.move 'right'
    else
      @hero.stop()

class Hero extends Phaser.Sprite
  @SPEED: 360

  constructor: ->
    super game, 275, 500, 'ship'
    @anchor.setTo 0.5, 0.5

  move: (direction) ->
    sign = if direction is 'left' then -1 else 1
    @body.velocity.x = Hero.SPEED * sign

  stop: ->
    @body.velocity.x = 0


class Bullet extends Phaser.Sprite
  @SPEED: 480

  constructor: (x, y) ->
    super game, x, y, 'bullet'
    @anchor.setTo 0.5, 0.5
    @outOfBoundsKill = true
    @init()

  init: ->
    @body.velocity.y = -Bullet.SPEED


class Alien extends Phaser.Sprite
  @MAX_SPEED_X: 240
  @MAX_SPEED_Y: 480
  @MIN_SPEED_Y: 180

  constructor: (x, y) ->
    super game, x, y, 'alien'
    @anchor.setTo 0.5, 0.5
    @outOfBoundsKill = true

    @animations.add 'fly', [0, 1], 3, true
    @animations.play 'fly'

    @init()

  init: ->
    @body.velocity.y = game.rnd.integerInRange Alien.MIN_SPEED_Y,
      Alien.MAX_SPEED_Y
    @body.velocity.x = game.rnd.integerInRange -Alien.MAX_SPEED_X,
      Alien.MAX_SPEED_X


class Explosion extends Phaser.Sprite
  @MAX_LIFESPAN: 1000

  constructor: (x, y) ->
    super game, x, y, 'explosion'
    @anchor.setTo 0.5, 0.5
    @animations.add 'boom', [0..11], 12, false
    @init()

  init: ->
    @animations.stop 'boom', true
    @animations.play 'boom'
    @lifespan = Explosion.MAX_LIFESPAN

    # tween scale
    startScale = game.rnd.realInRange 2.0, 3.5
    @scale.setTo startScale, startScale
    (game.add.tween @scale).to {x: startScale * 1.5, y: startScale * 1.5},
      @lifespan, Phaser.Easing.Linear.None, true, 0

    # tween alpha
    @alpha = 1.0
    (game.add.tween @).to {alpha: 0.0}, @lifespan, Phaser.Easing.Linear.None,
      true, 0


game = new Phaser.Game 550, 600, Phaser.WEBGL, 'game', PlayScene
