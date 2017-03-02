fs       = require 'fs'
path     = require 'path'
toRegExp = require 'to-regexp'

tmpDir = process.env.TMPDIR ? process.env.TMP ? process.env.TEMP ? '/tmp'

exports.excludeRe = defaultExcludeRe = /^\.|node_modules|npm-debug.log$|Cakefile|\.txt$|package.json$|\.map$|\.DS_Store/
exports.includeRe = defaultIncludeRe = /^\S/

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


# Split a potential pattern into a basePath + regex
splitPattern = (pattern) ->
  isGlob = (s) ->
    /[*?]/.exec s

  findBasePath = (pattern) ->
    paths = pattern.split '/'
    basePaths = []
    for p in paths
      if isGlob p
        break
      else
        basePaths.push p
    basePaths.join '/'

  basePath = findBasePath pattern
  pattern  = pattern.replace basePath, ''

  [basePath, pattern]

# Utility function to setup args for walk/watch
exports.parseArgs = (fn) ->
  (pattern, opts, cb) ->
    if typeof opts is 'function'
      [opts, cb] = [{}, opts]

    # Find basePath and possible globby
    [basePath, maybeGlobby] = splitPattern pattern

    # Expand home
    if (basePath.charAt 0) == '~'
      home = process.env.HOME ? process.env.HOMEPATH ? process.env.USERPROFILE
      basePath = path.join home, dir.substring 2

    # Get absolute path
    basePath = path.resolve basePath

    # Setup default include, exclude filters
    try
      excludeRe = toRegExp opts.exclude ? defaultExcludeRe

      # If you get a globby, use it
      if maybeGlobby
        includeRe = toRegExp opts.include ? defaultIncludeRe
      else
        includeRe = toRegExp maybeGlobby
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

      if includeRe?
        return true unless includeRe.test relname
      if excludeRe?
        return true if excludeRe.test relname

    opts.relative = relative
    opts.excluded = excluded

    fn basePath, opts, cb

# Find callback in an array of arguments
getcb = (args) ->
  for arg, i in args
    if typeof arg is 'function'
      cb = args.splice i, 1
      return [cb, i]

  [null, -1]

n = 0

# Debounce fn for given timeout
exports.debounce = (timeout, fn) ->
  running  = {}

  ->
    start = new Date()
    args = [].slice.call arguments
    key = JSON.stringify args

    # Don't start again if already running
    return if running[key]?

    # Mark this argument combination as running
    running[key] = true

    # Check for callback
    [cb, i] = getcb args

    # Clear flag after timeout
    done = ->
      end = new Date()
      diff = end - start
      if diff > timeout
        delete running[key]
      else
        wait = timeout - diff
        setTimeout ->
          delete running[key]
        , wait

    # Wrap callback if async
    if cb?
      args.splice i, 0, ->
        cb.apply null, arguments
        done()

    # Call debounced fn
    fn.apply null, args

    done() unless cb?
