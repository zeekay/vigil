for mod in ['run', 'utils', 'vm', 'watch', 'walk']
  do (mod) ->
    Object.defineProperty module.exports, mod,
      enumerable: true
      get: -> require "./#{mod}"
