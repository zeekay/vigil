Object.defineProperties module.exports,
  patch:
    enumerable: true
    get: -> require './patch'

  watch:
    enumerable: true
    get: -> require './watch'

  walk:
    enumerable: true
    get: -> require './walk'

