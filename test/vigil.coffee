fs      = require 'fs'
vigil   = require '../lib'
request = require 'request'
should  = (require 'chai').should()


describe 'vigil', ->
  describe '#walk', ->
    it 'should find all files and directories in test dir', (done) ->
      found = 0
      vigil.walk './test/assets', (filename, stats) ->
        done() if ++found == 5

  describe '#vm', ->
    it 'should find modules as they are required by node', (done) ->
      found = 0
      vigil.vm (filename, stats) ->
        done() if ++found == 2
      require '../test/assets/test-module'

  describe '#watch', ->
    it 'should detect filechanges', (done) ->
      found = 0
      vigil.watch './test/assets', (filename, stats, isModule) ->
        done() if ++found == 2
      require '../test/assets/test-module-2'
      fs.writeFileSync './test/assets/test-module-2', ''
      fs.writeFileSync './test/assets/2/3', ''

  describe '#run', ->
    it 'should run a server module and reload on changes', (done) ->
      vigil.run ->
        require './test/assets/test-server'
      , ->
        request 'http://localhost:3333', (err, res, body) ->
          body.should.equal 'test'
          done()

  describe '#utils.globToRegex', ->
    it 'should convert various glob patterns into regex correctly', ->
      patterns =
        'foo*': '/^foo.*$/'
        'foobar*': '/^foobar.*$/'
        '[bc]ar': '/^[bc]ar$/'
        'foo/bar': '/^foo\\/bar$/'
      for glob, regexStr of patterns
        do (glob, regexStr) ->
          regex = vigil.utils.globToRegex glob
          regex.toString().should.equal regexStr

