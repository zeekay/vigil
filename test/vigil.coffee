fs    = require 'fs'
vigil = require '../lib'


describe 'vigil', ->
  describe '#walk', ->
    it 'should find all files and directories in test dir', (done) ->
      found = 0
      console.log()
      vigil.walk __dirname + '/assets', (filename, stats) ->
        console.log filename
        done() if ++found == 5

  describe '#vm', ->
    it 'should find modules as they are required by node', (done) ->
      found = 0
      console.log()
      vigil.vm (filename, stats) ->
        console.log filename
        done() if ++found == 2
      require __dirname + '/assets/test-module'

  describe '#watch', ->
    it 'should detect filechanges', (done) ->
      found = 0
      console.log()
      vigil.watch __dirname + '/assets', (filename, stats, isModule) ->
        console.log filename, isModule
        done() if ++found == 2
      require __dirname + '/assets/test-module-2'
      fs.writeFileSync __dirname + '/assets/test-module-2', ''
      fs.writeFileSync __dirname + '/assets/2/3', ''
