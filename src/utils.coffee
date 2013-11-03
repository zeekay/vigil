fs   = require 'fs'
path = require 'path'

tmpDir = process.env.TMPDIR ? process.env.TMP ? process.env.TEMP ? '/tmp'

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
