Object.defineProperties module.exports,
  patch:
    enumerable: true
    get: -> require './patch'

  run:
    enumerable: true
    get: -> require './run'

  watch:
    enumerable: true
    get: -> require './watch'

  walk:
    enumerable: true
    get: -> require './walk'
