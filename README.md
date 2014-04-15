# vigil
Simple, efficient file watcher for node.

### Example
```javascript
vigil.watch('src/*.coffee', function(filename, stats) {
    exec('coffee -bcm ' + filename)
})
```

### API
#### vigil.run(fn, cb)
Executes `fn` (typically a server), watching modules required into VM for
changes and executing `cb` on change events.

#### vigil.vm(cb)
Watches modules required into VM for changes, executing `cb` on change events

#### vigil.walk(path, cb)
Walks `path`, calling `cb` with `(filename,
stats)` for each file found (optionally matching glob pattern).

#### vigil.watch(path, cb)
Watches `path` for changes, calling `cb` with `(filename, stats, isModule)` on
change.
