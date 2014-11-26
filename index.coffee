os = require 'os'
_ = require 'lodash'


platforms =
    darwin: -> 'osx' + if process.arch is 'ia32' then 32 else 64
    osx: -> 'osx' + if process.arch is 'ia32' then 32 else 64
    osx32: -> 'osx32'
    osx64: -> 'osx64'
    win: -> 'win' + if process.arch is 'ia32' then 32 else 64
    win32: -> 'win32'
    win64: -> 'win64'
    linux: -> 'linux' + if process.arch is 'ia32' then 32 else 64

# Returns a {String}
detectPlatform = ->
    return platforms[os.platform()]()

normalizePlatform = (platform) ->
    return if platforms[platform]? then platforms[platform]() else platform


# args - {Object}
#       :options - {Object} or {String}
#       :platform - Optional {String}. One of the following: [osx32, osx64, win32, win64, linux32, linux64]. If not passed, current
#                   platform is detected
# cb - {Function}. Called with Error and result arguments
# Returns an {String} or {Object}, depending on `objectMode` parameter
module.exports = (args, cb) ->
    cb = (->) unless cb?
    platform = if args.platform then normalizePlatform args.platform else normalizePlatform detectPlatform()
    objectMode = _.isPlainObject args.options

    try
        options = if objectMode then args.options else JSON.parse args.options
    catch err
        return cb err, null


    if options.platformOverrides?
        result = _.clone options, true
        if options.platformOverrides[platform]? and Object.keys(options.platformOverrides[platform]).length
            result = _.merge(
                result,
                options.platformOverrides[platform],
                (optionValue, overrideValue) ->
                    ###
                      If overrides.x is {} but source.x is a non-empty object {prop:0, another:2},
                      take the {}}
                    ###
                    overrideValue if (_.isPlainObject(overrideValue) or  _.isArray overrideValue) and  _.isEmpty overrideValue
            )
        delete result.platformOverrides

        cb null, if objectMode then result else JSON.stringify result
    else
        cb null, args.options
