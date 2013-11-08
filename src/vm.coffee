fs   = require 'fs'
path = require 'path'
vm   = require 'vm'


module.exports = (cb) ->
  hooks = {}
  seen  = {}

  # lookup dir and cb with filename dir if exists
  found = (filename) ->
    dir = path.dirname filename

    unless seen[dir]
      seen[dir] = true

      fs.stat dir, (err, stats) ->
        return unless stats?
        cb dir, stats

    fs.stat filename, (err, stats) ->
      return unless stats?
      cb filename, stats

  updateHooks = ->
    for ext, handler of require.extensions
      do (ext, handler) ->
        if hooks[ext] != require.extensions[ext]
          hooks[ext] = require.extensions[ext] = (module, filename) ->
            # callback with module if it hasn't been loaded before
            found module.filename unless module.loaded

            # Invoke original handler
            handler module, filename

            # Make sure the module did not hijack the handler
            updateHooks()

  # Hook 'em.
  updateHooks()

  # Patch VM module
  methods =
    createScript:     1
    runInThisContext: 1
    runInNewContext:  2
    runInContext:     2

  for method, idx of methods
    original = vm[method]
    vm[method] = ->
      found filename if filename = arguments[idx]
      original.apply vm, arguments
