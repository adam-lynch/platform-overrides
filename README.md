platform-overrides [![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url] [![Dependency Status][depstat-image]][depstat-url]
==========

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
        platform: 'osx' // auto-detected if omitted
    }, function(err, result){
        if(err) //...

        // result will be a JSON string but the "a" property will contain 1 now
    });
```


## API

`platformOverrides(options, callback)`

**Returns** an Object or String, depending on what the type of the `options` property passed.

### Options

#### options
Object or String. (i.e. `options.options`)

#### platform
(Optional) String. One of the following: [osx, win, linux32, linux64]. If not passed, the current platform is detected.

Note: `osx` is not `mac` just for the sake of backwards compatibility with [node-webkit-builder](https://github.com/mllrsohn/node-webkit-builder).


### Callback

Function called on completion with error and result arguments; e.g. `function(err, result){}`

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

[npm-url]: https://npmjs.org/package/platform-overrides
[npm-image]: http://img.shields.io/npm/v/platform-overrides.svg?style=flat

[travis-url]: http://travis-ci.org/adam-lynch/platform-overrides
[travis-image]: http://img.shields.io/travis/adam-lynch/platform-overrides.svg?style=flat

[depstat-url]: https://david-dm.org/adam-lynch/platform-overrides
[depstat-image]: https://david-dm.org/adam-lynch/platform-overrides.svg?style=flat
