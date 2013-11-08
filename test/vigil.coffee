vigil = require '../lib'

describe 'vigil', ->
  describe '#walk', ->
    it 'should find all files and directories in test dir', (done) ->
      found = 0
      console.log()
      vigil.walk __dirname + '/assets', (filename, stats) ->
        console.log filename
        done() if ++found == 4

  describe '#vm', ->
    it 'should find modules as they are required by node', (done) ->
      found = 0
      console.log()
      vigil.vm (filename, stats) ->
        console.log filename
        done() if ++found == 2
      require __dirname + '/assets/test-module'
