fs      = require 'fs'
os      = require('os')
request = require 'request'
should  = (require 'chai').should()

vigil   = require '../lib'


describe 'vigil', ->
  describe '#walk', ->
    it 'should find all files and directories in test dir', (done) ->
      found = 0
      vigil.walk './test/assets', (filename, stats) ->
        done() if ++found == 5

    it 'should convert globby basepaths into include regex', (done) ->
      found = 0
      vigil.walk './test/assets/*.js', (filename, stats) ->
        unless /.*.js/.test filename
          throw new Error 'file does not match regex', filename
        done() if ++found == 2

  describe '#watch', ->
    it 'should detect filechanges', (done) ->
      found = 0
      vigil.watch './test/assets', (filename, stats, isModule) ->
        # each platform behaves slightly differently :(
        if os.platform() == 'darwin'
          done() if ++found == 2
        else
          done()

      require '../test/assets/test-module-2'
      fs.writeFileSync './test/assets/test-module-2', ''
      fs.writeFileSync './test/assets/2/3', ''

  # TODO: Figure out if/how to fix in Node 7+
  describe.skip '#vm', ->
    it 'should find modules as they are required by node', (done) ->
      found = 0
      vigil.vm (filename, stats) ->
        done() if ++found == 2
      require '../test/assets/test-module'

  describe.skip '#run', ->
    it 'should run a server module and reload on changes', (done) ->
      vigil.run ->
        require './test/assets/test-server'
      , ->
        request 'http://localhost:3333', (err, res, body) ->
          body.should.equal 'test'
          done()
