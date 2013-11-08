cluster = require 'cluster'
fs      = require 'fs'
path    = require 'path'
utils   = require './utils'
watch   = require './watch'

_watch = (dir) ->
  require('vigil').watch dir, (filename, stats, isModule) ->
    console.log "#{filename} changed, reloading"
    process.exit 0

module.exports = (fn) ->
  utils.tmpFile '.worker-tmp', (err, filename, fd) ->
    throw err if err?

    code = """
           // try to require coffee-script so subsequent requires to coffee files works
           try {
             require('coffee-script');
           } catch (err) {
             // do nothing, coffee-script isn't supported, oh well
           }

           // change mainModule to fake file in cwd, so requires work as expected
           process.mainModule.filename = '#{path.join process.cwd(), 'tmp-worker'}';

           // set __dirname
           __dirname = '#{process.cwd()}';

           // start watching cwd for changes
           (#{_watch.toString()}('#{process.cwd()}'));

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
