fs    = require 'fs'
path  = require 'path'

vm = require './vm'
walk = require './walk'
{parseArgs} = require './utils'


module.exports = parseArgs (basePath, opts, cb) ->
  {relative, excluded} = opts
  opts.patch          ?= true
  opts.recurse        ?= true
  opts.watchSymlink   ?= false
  modules              = {}
  watching             = {}

  watch = (dir, isModule) ->
    return modules[dir] = true if isModule

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

        # watch real dir of symbolic link
        else if stats.isSymbolicLink() and opts.watchSymlink
          fs.readLink filename, (err, realPath) ->
            watch path.dirname realPath

        else
          # callback with modified file
          cb (relative filename), stats, modules[filename] ? false

  watch basePath

  if opts.recurse
    walk basePath, opts, (filename, stats) ->
      return if excluded filename

      watch filename if stats.isDirectory()

  if opts.patch
    vm (filename, stats) ->
      return if excluded filename

      watch filename, true if stats.isDirectory()

  watch
