fs   = require 'fs'
path = require 'path'

{parseArgs} = require './utils'


module.exports = parseArgs (basePath, opts, cb) ->
  {relative, excluded} = opts

  walk = (dir) ->
    fs.readdir dir, (err, files) ->
      return unless files?

      for filename in files
        do (filename) ->
          filename = path.join dir, filename

          return if excluded filename

          # stat file
          fs.stat filename, (err, stats) ->
            return unless stats?

            # callback with filename
            cb filename, stats

            # continue walking if directory
            walk filename if stats.isDirectory()

  # begin walking dir
  walk basePath
