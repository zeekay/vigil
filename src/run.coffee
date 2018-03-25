import cluster from 'cluster'
import fs      from 'fs'
import path    from 'path'

import {tmpFile} from './utils'
import watch     from './watch'

_watch = (dir) ->
  require('vigil').watch dir, (filename, stats, isModule) ->
    console.log "#{filename} changed, reloading"
    process.exit 0

export default run = (fn, cb = ->) ->
  tmpFile '.worker-tmp', (err, filename, fd) ->
    throw err if err?

    code = """
           // try to require coffeescript so subsequent requires to coffee files works
           try {
             // CoffeeScript 1.7+
             require('coffeescript/register');
           } catch (err) {
             // do nothing, coffeescript isn't supported, oh well
           }

           // change mainModule to fake file in cwd, so requires work as expected
           process.mainModule.filename = '#{path.join process.cwd(), 'tmp-worker'}';

           // set __dirname
           __dirname = '#{process.cwd()}';

           // start watching cwd for changes
           (#{_watch.toString().replace 'vigil', __dirname}('#{process.cwd()}'));

           // execute callback as worker process
           (#{fn.toString()}());
           """

    fs.write fd, code, 0, 'utf8', (err) ->
      throw err if err?

      fs.close fd, ->
        cluster.setupMaster
          exec: filename
          silent: false

        cluster.fork()

        cluster.on 'exit', (worker, code, signal) ->
          cluster.fork()

        cluster.once 'listening', -> cb()
