platform-overrides [![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url] [![Dependency Status][depstat-image]][depstat-url]
==========

Allows you to specify platform-specific manifest values. Work with JSON or plain objects. 
                     
The platform-specific options will override the others only when "building" for that platform and the `platformOverrides` property will be removed.

This was originally created with [node-webkit](http://github.com/rogerwang/node-webkit) in mind.

## Installation

```shell
npm install platform-overrides
```

## Usage

```javascript
var platformOverrides = require('platform-overrides');

var result = platformOverrides({
        options: '{"a": 0, "platformOverrides": { "mac": { "a": 1 } } }',
        platform: 'mac'
    });
// result will be a JSON string but the "a" property will contain 1 now
```


### Options

#### objectMode
(Optional) Boolean. If `true`, the `options` argument you pass will have to be an Object and the return value will be an Object too

#### options
Object or String, depending on `objectMode` parameter

#### platform
(Optional) String. One of the following: [mac, win, linux32, linux64]. If not passed, the current platform is detected

## Example

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
      "osx": {
          ...
      },
      "linux32": {
          ...
      },
      "linux64": {
          ...
      },
  }
}
``` 

For example, when building for Windows, the manifest generated and put into the end app (from the manifest above) would be:

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

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

[npm-url]: https://npmjs.org/package/gulp-bless
[npm-image]: http://img.shields.io/npm/v/gulp-bless.svg?style=flat

[travis-url]: http://travis-ci.org/adam-lynch/gulp-bless
[travis-image]: http://img.shields.io/travis/adam-lynch/gulp-bless.svg?style=flat

[depstat-url]: https://david-dm.org/adam-lynch/gulp-bless
[depstat-image]: https://david-dm.org/adam-lynch/gulp-bless.svg?style=flat