import fs   from 'fs'
import path from 'path'

import vm   from './vm'
import walk from './walk'
import {debounce, parseArgs} from './utils'

export default watch = parseArgs (basePath, opts, cb) ->
  {relative, excluded} = opts
  opts.patch          ?= false
  opts.recurse        ?= true
  opts.watchSymlink   ?= false

  modules              = {}
  watching             = {}

  watch = (dir, isModule) ->
    return modules[dir] = true if isModule
    return if watching[dir]

    onchange = (event, filename) ->
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

        # file changed
        else
          # Callback with file, stats object, module boolean
          cb filename, stats, modules[filename] ? false

    watching[dir] = fs.watch dir, (debounce 500, onchange)

  watch basePath

  if opts.recurse
    walk basePath, opts, (filename, stats) ->
      if excluded filename
        return

      watch filename if stats.isDirectory()

  if opts.patch
    vm (filename, stats) ->
      if excluded filename
        return

      watch filename, true if stats.isDirectory()

  watch
