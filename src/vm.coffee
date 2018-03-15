import fs    from 'fs'
import path  from 'path'
import patch from './patch'


export default vm = (cb) ->
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
  patch found
