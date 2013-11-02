fs    = require 'fs'
walk  = require './walk'
patch = require './patch'
path  = require 'path'

module.exports = (dir, opts, cb) ->
  if typeof opts is 'function'
    [cb, opts] = [opts, {}]

  opts.patch ?= true

  watching = {}

  watch = (dir) ->
    watching[dir].close() if watching[dir]

    watching[dir] = fs.watch dir, (event, filename) ->
      filename = path.join dir, filename

      fs.stat filename, (err, stats) ->
        return unless stats? and not err?

        # callback with modified file
        cb filename

        # watch new directory created
        watch filename if stats.isDirectory()

  walk dir, (filename, stats) ->
    watch filename if stats.isDirectory()

  if opts.patch
    patch (filename, stats) ->
      watch filename if stats.isDirectory()
