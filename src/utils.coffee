fs   = require 'fs'
path = require 'path'

tmpDir = process.env.TMPDIR ? process.env.TMP ? process.env.TEMP ? '/tmp'

exports.excludeRe = defaultExcludeRe = /^\.|node_modules|npm-debug.log$|Cakefile|\.md$|\.txt$|package.json$|\.map$|\.DS_Store/
exports.includeRe = defaultIncludeRe = /[^\s\S]/

tmpName = (prefix, cb, tries = 0) ->
  if tries > 5
    return cb new Error 'max tries exceeded'

  filename = path.join tmpDir, "#{prefix}-#{(Math.random() * 0x1000000000).toString(36)}"
  # filename = "#{prefix}-#{(Math.random() * 0x1000000000).toString(36)}"
  fs.exists filename, (exists) ->
    if exists
      tmpName cb, tries + 1
    else
      cb null, filename

exports.tmpFile = (prefix, cb) ->
  tmpName prefix, (err, filename) ->
    return cb err if err?

    fs.open filename, 'wx+', (err, fd) ->
      return cb err if err?

      cb null, filename, fd

      cleanup = ->
        fs.unlinkSync filename

      process.addListener 'uncaughtException', cleanup
      process.addListener 'exit', cleanup

exports.globToRegex = (s) ->
  chars = (c for c in s)
  re = '^'

  while chars.length > 0
    c = chars.shift()
    switch c
      # escape
      when '/', '$', '^', '+', '?', '.', '(', ')', '=', '!', '|', '{', '}', ','
        re += '\\' + c

      # this is an escaped character
      when '\\'
        re += '\\\\' + chars.shift()

      # convert glob special characters
      when '*'
        re += '.*'

      when '?'
        re += '.'

      when '['
        re += c
        while chars.length > 0 and c != ']'
          c = chars.shift()
          re += c

      # normal character
      else
        re += c

  re += '$'

  new RegExp re

parsePattern = (pattern) ->
  return unless pattern?

  if Array.isArray pattern or typeof pattern == 'string'
    utils.globToRegex pattern
  else if pattern instanceof RegExp
    pattern
  else
    throw new Error 'expected RegExp or glob pattern(s)'

# utility function to setup args for walk/watch
exports.parseArgs = (fn) ->
  (basePath, opts, cb) ->
    if typeof opts is 'function'
      [opts, cb] = [{}, opts]

    # expand home
    if (basePath.charAt 0) == '~'
      home = process.env.HOME ? process.env.HOMEPATH ? process.env.USERPROFILE
      basePath = path.join home, dir.substring 2

    # get absolute path
    basePath = path.resolve basePath

    try
      excludeRe = (parsePattern opts.exclude) ? defaultExcludeRe
      includeRe = (parsePattern opts.include) ? defaultIncludeRe
    catch err
      return cb err

    # get path relative to basePath if possible
    relative = (filename) ->
      if (filename.indexOf basePath) == 0
        (filename.substring basePath.length).replace /^\//, ''
      else
        filename

    # test whether filename is excluded
    excluded = (filename) ->
      relname = relative filename
      (excludeRe.test relname) and not (includeRe.test relname)

    opts.relative = relative
    opts.excluded = excluded

    fn basePath, opts, cb
