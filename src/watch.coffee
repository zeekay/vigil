fs    = require 'fs'
path  = require 'path'

vm = require './vm'
walk = require './walk'
{parseArgs} = require './utils'


module.exports = parseArgs (basePath, opts, cb) ->
  {relative, excluded} = opts
  opts.patch          ?= true
  modules              = {}
  watching             = {}

  watch = (dir) ->
    watching[dir].close() if watching[dir]

    watching[dir] = fs.watch dir, (event, filename) ->
      filename = path.join dir, filename

      return if excluded filename

      fs.stat filename, (err, stats) ->
        # ignore non-existent files
        return if err? or not stats?

        # watch new directory created
        if stats.isDirectory()
          watch filename
        else
          # callback with modified file
          cb (relative filename), stats, modules[filename] ? false

  walk basePath, opts, (filename, stats) ->
    return if excluded filename

    watch filename if stats.isDirectory()

  if opts.patch
    vm (filename, stats) ->
      return if excluded filename

      modules[filename] = true

      watch filename if stats.isDirectory()
