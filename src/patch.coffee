import vm from 'vm'

nodeVersion = ->
  parseInt process.version.substring(1).split('.')[0], 10

export default patch = (found) ->
  createScript     = vm.createScript
  runInContext     = vm.runInContext
  runInNewContext  = vm.runInNewContext
  runInThisContext = vm.runInThisContext

  if nodeVersion() >= 7
    vm.createScript = (code, options) ->
      found filename if ({filename} = options)?
      createScript code, options

    vm.runInContext = (code, contextifiedSandbox, options) ->
      found filename if ({filename} = options)?
      runInContext code, contextifiedSandbox, options

    vm.runInNewContext = (code, sandbox, options) ->
      found filename if ({filename} = options)?
      runInNewContext code, sandbox, options

    vm.runInThisContext = (code, options) ->
      found filename if ({filename} = options)?
      runInThisContext code, options
  else
    vm.createScript = (code, filename, disp) ->
      found filename if filename?
      createScript code, filename, disp

    vm.runInContext = (code, sandbox, filename, timeout, disp) ->
      found filename if filename?
      runInContext code, sandbox, filename, timeout, disp

    vm.runInNewContext = (code, sandbox, filename, timeout, disp) ->
      found filename if filename?
      runInNewContext code, sandbox, filename, timeout, disp

    vm.runInThisContext = (code, filename, timeout, disp) ->
      found filename if filename?
      runInThisContext code, filename, timeout, disp
