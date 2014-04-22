exec = require('executive').interactive

option '-g', '--grep [filter]', 'test filter'
option '-v', '--version [<newversion> | major | minor | patch | build]', 'new version'

task 'clean', 'clean project', (options) ->
  exec 'rm -rf lib'
  exec 'rm -rf .test'

task 'build', 'build project', (options) ->
  exec 'node_modules/.bin/coffee -bcm -o lib/ src/'
  exec 'node_modules/.bin/coffee -bcm -o .test/ test/'

task 'test', 'run tests', ->
  exec "NODE_ENV=test ./node_modules/.bin/mocha
                      --colors
                      --reporter spec
                      --timeout 5000
                      --compilers coffee:coffee-script/register
                      --require postmortem/register
                      .test"

task 'watch', 'watch for changes and recompile project', ->
  exec './node_modules/.bin/coffee -bc -m -w -o lib/ src/'

task 'publish', 'publish project', (options) ->
  newVersion = options.version ? 'patch'

  exec """
  git push
  npm version #{newVersion}
  npm publish
  """.split '\n'
