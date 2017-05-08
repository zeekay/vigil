# vigil

[![npm][npm-img]][npm-url]
[![build][build-img]][build-url]
[![dependencies][dependencies-img]][dependencies-url]
[![downloads][downloads-img]][downloads-url]
[![license][license-img]][license-url]
[![chat][chat-img]][chat-url]

> Simple, fast, efficient file watcher for node.

## Install
```bash
$ npm install vigil --save
```

### API
#### `vigil.run(fn, cb)`
Executes `fn` (typically a server), watching modules required into VM for
changes and executing `cb` on change events.

#### `vigil.vm(cb)`
Watches modules required into VM for changes, executing `cb` on change events

#### `vigil.walk(path, cb)`
Walks `path`, calling `cb` with `(filename,
stats)` for each file found (optionally matching glob pattern).

#### `vigil.watch(path, cb)`
Watches `path` for changes, calling `cb` with `(filename, stats, isModule)` on
change.

### Example
```javascript
vigil.watch('src/*.coffee', function(filename, stats) {
    exec('coffee -bcm ' + filename)
})
```

Check the tests for [more examples][examples].

## License
[MIT][license-url]

[examples]:         https://github.com/zeekay/vigil/blob/master/test/vigil.coffee

[build-img]:        https://img.shields.io/travis/zeekay/vigil.svg
[build-url]:        https://travis-ci.org/zeekay/vigil
[chat-img]:         https://badges.gitter.im/join-chat.svg
[chat-url]:         https://gitter.im/zeekay/hi
[coverage-img]:     https://coveralls.io/repos/zeekay/vigil/badge.svg?branch=master&service=github
[coverage-url]:     https://coveralls.io/github/zeekay/vigil?branch=master
[dependencies-img]: https://david-dm.org/zeekay/vigil.svg
[dependencies-url]: https://david-dm.org/zeekay/vigil
[downloads-img]:    https://img.shields.io/npm/dm/vigil.svg
[downloads-url]:    http://badge.fury.io/js/vigil
[license-img]:      https://img.shields.io/npm/l/vigil.svg
[license-url]:      https://github.com/zeekay/vigil/blob/master/LICENSE
[npm-img]:          https://img.shields.io/npm/v/vigil.svg
[npm-url]:          https://www.npmjs.com/package/vigil
