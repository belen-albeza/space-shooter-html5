Space Shooter HTML5
===================

This is my particular version of 'Hello World' when I try a new game engine / framework.

You can play online at [lab.belenalbeza.com/games/space-shooter](http://lab.belenalbeza.com/games/space-shooter/).

The game is coded with **CoffeeScript** and uses the [Phaser](http://phaser.io/) framework.

## Author

© 2014 Belén Albeza. Code and assets are published under the MIT License. See `LICENSE` for details.

## If you want to tinker

The game uses Bower to manage dependencies, and Grunt to automate development and generate releases.

### Requirements

- Node and npm
- Bower `npm install -g bower`
- Grunt `npm install -g grunt-cli`

### Setup

Clone or fork the repository:

```
git clone git@github.com:belen-albeza/space-shooter-html5.git
cd space-shooter-html5
```

Install Bower dependencies:

```
bower install
```

Install Node dependencies (they are used by Grunt):

```
npm install
```

Game code is included in `app/coffee`. You can compile it and launch it in a local server by running:

```
grunt server
```

You can play the code by accessing [0.0.0.0:9000](http://0.0.0.0:9000) in a browser.

If you want to generate a release (i.e. files you can upload to your server so others can play the game):

```
grunt release
```




