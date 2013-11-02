fs   = require 'fs'
path = require 'path'

module.exports = (dir, opts = {}, cb) ->
  if typeof opts is 'function'
    [opts, cb] = [{}, opts]

  # expand home
  if (dir.charAt 0) == '~'
    home = process.env.HOME ? process.env.HOMEPATH ? process.env.USERPROFILE
    dir = path.join home, dir.substring 2

  # get absolute path
  dir = path.resolve dir

  # ignore filter
  ignore = opts.ignore ? /\.git|\.hg|\.svn|node_modules/

  # readdir recursively
  walk = (dir) ->
    fs.readdir dir, (err, files) ->
      return unless files?

      for file in files
        do (file) ->
          return if ignore.test file

          file = path.join dir, file

          # stat file
          fs.stat file, (err, stats) ->
            return unless stats?

            # callback with file
            cb file, stats

            # continue walking if directory
            walk file if stats.isDirectory()

  # begin walking dir
  walk dir
