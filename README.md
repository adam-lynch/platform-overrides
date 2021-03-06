platform-overrides 
==========

[![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url] [![Windows Build Status][appveyor-image]][appveyor-url] [![Dependency Status][depstat-image]][depstat-url] 

---

Apply platform-specific manifest values. Works with JSON or plain objects. 
                     
The platform-specific options will override the others only when "building" for that platform and the `platformOverrides` property will be removed.

This was originally created with [node-webkit](http://github.com/rogerwang/node-webkit) in mind.

Need a Gulp plugin? See [gulp-platform-overrides](http://github.com/adam-lynch/gulp-platform-overrides).

## Installation

```shell
npm install platform-overrides
```

## Usage

```javascript
var platformOverrides = require('platform-overrides');

var result = platformOverrides({
        options: '{"a": 0, "platformOverrides": { "osx": { "a": 1 } } }',
        platform: 'osx' // auto-detects a platform if omitted
    }, function(err, result){
        if(err) //...

        // result will be a JSON string but the "a" property will contain 1 now
    });
```


## API

`platformOverrides(options, callback)`

**Returns** an Object or String, depending on the type of the `options` property you passed.

### Options

#### options
Object or String. (i.e. `options.options`)

#### platform
(Optional) String. One of the following: [osx, osx32, osx64, win, win32, win64, linux, linux32, linux64].

If not passed, the current platform is detected (the auto-detected platform is always an architecture-specific one (i.e. has `32` / `64` on the end).

See [Examples](#examples) for how this parameter effects the behaviour of this plugin.

Note: `osx` is not `mac` just for the sake of backwards compatibility with [node-webkit-builder](https://github.com/mllrsohn/node-webkit-builder).


### Callback

Function called on completion with error and result arguments; e.g. `function(err, result){}`

## Examples

Example manifest:

```json
{
  "name": "nw-demo",
  "version": "0.1.0",
  "main": "index.html",
  "window": {
      "frame": false,
      "toolbar": false
  },
  "platformOverrides": {
      "win": {
          "window": {
              "frame": true
          }
      },
      "osx64": {
          ...
      },
      ...
  }
}
``` 

For example, when building for Windows (passing `win` as the platform or not passing a platform on a Windows machine), the manifest generated and put into the end app (from the manifest above) would be:

```json
{
    "name": "nw-demo",
    "version": "0.1.0",
    "main": "index.html",
    "window": {
        "frame": true,
        "toolbar": false
    }
}
```

### Architecture-agnostic

Example manifest:

```json
{
  "name": "nw-demo",
  "platformOverrides": {
      "win": {
          "name": "hello"
      },
      "win32": {
          "name": "world"
      },
      "win64": {
          "name": "like"
      }
      ...
  }
}
```

If `win` is passed as the platform, then only `win` is applied and `win32` & `win64` are ignored;

```json
{
    "name": "hello"
}
```


### Specificity & Cascading


Example manifest:

```json
{
  "name": "nw-demo",
  "version": "0.1",
  "platformOverrides": {
      "win": {
          "name": "hello",
          "version": "0.2"
      },
      "win32": {
          "version": "0.3"
      },
      "win64": {
          "name": "like"
      }
      ...
  }
}
```

If `win32` is passed as the platform (or `win32` is auto-detected), then `win` is applied first, then `win32`;

```json
{
      "name": "hello",
      "version": "0.3"
}
```

Even if there is no `win32`, then the `win` platform overrides will still be applied.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

[npm-url]: https://npmjs.org/package/platform-overrides
[npm-image]: http://img.shields.io/npm/v/platform-overrides.svg?style=flat

[travis-url]: http://travis-ci.org/adam-lynch/platform-overrides
[travis-image]: http://img.shields.io/travis/adam-lynch/platform-overrides.svg?style=flat

[appveyor-url]: https://ci.appveyor.com/project/adam-lynch/platform-overrides/branch/master
[appveyor-image]: https://ci.appveyor.com/api/projects/status/iomo0qtm5k59jyw9/branch/master?svg=true

[depstat-url]: https://david-dm.org/adam-lynch/platform-overrides
[depstat-image]: https://david-dm.org/adam-lynch/platform-overrides.svg?style=flat
