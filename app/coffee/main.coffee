PlayScene =
  preload: ->
    game.load.image 'ship', 'images/captain.png'
    game.load.image 'background', 'images/background.png'

  create: ->
    @cursors = game.input.keyboard.createCursorKeys()

    game.add.sprite 0, 0, 'background'
    @hero = game.add.existing new Hero

  update: ->
    if @cursors.left.isDown
      @hero.move 'left'
    else if @cursors.right.isDown
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


game = new Phaser.Game 550, 600, Phaser.WEBGL, 'game', PlayScene
