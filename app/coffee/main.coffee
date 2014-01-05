PlayScene =
  preload: ->
    # images
    game.load.image 'background', 'images/background.png'
    game.load.image 'ship', 'images/captain.png'
    game.load.image 'bullet', 'images/laser.png'
    game.load.spritesheet 'alien', 'images/alien.png', 48, 42
    game.load.spritesheet 'explosion', 'images/explosion.png', 50, 50
    game.load.image 'hud', 'images/hud.png'
    game.load.image 'energy_bg', 'images/energy_low.png'
    game.load.image 'energy_fg', 'images/energy_full.png'

    # audio
    game.load.audio 'sfx_explosion', ['sounds/explosion.wav']
    game.load.audio 'sfx_shoot', ['sounds/shoot.wav']
    game.load.audio 'sfx_bgm', ['sounds/gothic_dreams.mp3',
      'sounds/gothic_dreams.ogg']

  create: ->
    # game logic attributes
    @score = 0

    # create sprites
    game.add.sprite 0, 0, 'background'
    @aliens = game.add.group()
    @bullets = game.add.group()
    @explosions = game.add.group()
    @hero = game.add.existing new Hero
    @hud = game.add.group()

    # create audio samples
    @sfxShoot = game.add.audio 'sfx_shoot', 0.5
    @sfxExplosion = game.add.audio 'sfx_explosion', 0.5
    @sfxBackground = game.add.audio 'sfx_bgm', 1, true
    @sfxBackground.play()

    @_setupHud @hud

    # setup input
    @kbCursors = game.input.keyboard.createCursorKeys()
    @kbSpace = game.input.keyboard.addKey Phaser.Keyboard.SPACEBAR
    @kbSpace.onDown.add @_shoot, @

    # on game over condition
    @hero.events.onKilled.add =>
      @_gameOver()

  update: ->
    @_handleInput()

    # spawn aliens
    @_spawnAlien() if (game.rnd.integerInRange 0, 100) < 10

    # handle collisions
    game.physics.collide @bullets, @aliens, (bullet, alien) =>
      @_spawnExplosionAt alien.x, alien.y
      bullet.kill()
      alien.kill()
      @score += 10
    game.physics.collide @hero, @aliens, (hero, alien) =>
      @_spawnExplosionAt alien.x, alien.y
      alien.kill()
      hero.damage 1

    @_updateHud()

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
    @sfxShoot.play()

  _spawnAlien: ->
    @_spawnSprite @aliens, Alien, game.world.randomX, -20

  _spawnExplosionAt: (x, y) ->
    @_spawnSprite @explosions, Explosion, x, y
    @sfxExplosion.play()

  _handleInput: ->
    if @kbCursors.left.isDown
      @hero.move 'left'
    else if @kbCursors.right.isDown
      @hero.move 'right'
    else
      @hero.stop()

  _setupHud: ->
    @hud.create 2, 538, 'hud'

    @scoreText = game.add.text 540, 542, '' + @score, {
      font: '32pt monospace'
      fill: '#fff'
    }, @hud
    @scoreText.anchor.setTo 1.0, 0.0

    @hud.create 15, 545, 'energy_bg'
    @energyBar = @hud.create 15, 545, 'energy_fg'
    @energyBar.cropEnabled = true

  _updateHud: ->
    @scoreText.setText @score
    @energyBar.crop.width = if @hero? then \
      Math.max 0, (@hero.health + 1) / (Hero.MAX_HEALTH + 1) * @energyBar.width
    else \
      0

  _gameOver: ->
    # show game over title
    title = game.add.text 275, 250, 'Game Over', {
      font: '32pt monospace', fill: '#fff'
    }, @hud
    title.anchor.setTo 0.5, 0.5

    # show subtitle and allow restart of the game after a few seconds
    callback = =>
      subtitle = game.add.text 275, 290, 'Press SPACE to restart', {
        font: '16pt monospace', fill: '#fff'
      }, @hud
      subtitle.anchor.setTo 0.5, 0.5

      # restart the game when space bar is pressed
      @kbSpace.onDown.add ->
        game.state.start 'play'

    setTimeout callback, 1500
    @kbSpace.onDown.removeAll()

  shutdown: ->
    @sfxBackground.stop()

class Hero extends Phaser.Sprite
  @SPEED: 360
  @MAX_HEALTH: 4

  constructor: ->
    super game, 275, 500, 'ship'
    @anchor.setTo 0.5, 0.5
    @health = Hero.MAX_HEALTH
    @body.immovable = true
    @body.collideWorldBounds = true

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


game = new Phaser.Game 550, 600, Phaser.WEBGL, 'game'
game.state.add 'play', PlayScene
game.state.start 'play'
