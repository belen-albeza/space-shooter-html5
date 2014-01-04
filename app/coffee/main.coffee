PlayScene =
  preload: ->
    game.load.image 'background', 'images/background.png'
    game.load.image 'ship', 'images/captain.png'
    game.load.image 'bullet', 'images/laser.png'

  create: ->
    # create sprites
    game.add.sprite 0, 0, 'background'
    @bullets = game.add.group()
    @hero = game.add.existing new Hero

    # setup input
    @kbCursors = game.input.keyboard.createCursorKeys()
    kbSpace = game.input.keyboard.addKey Phaser.Keyboard.SPACEBAR
    kbSpace.onDown.add @_shoot, @

  update: ->
    @_handleInput()

  _shoot: ->
    @bullets.add new Bullet @hero.x, @hero.y - 20

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

    @body.velocity.y = -Bullet.SPEED


game = new Phaser.Game 550, 600, Phaser.WEBGL, 'game', PlayScene
