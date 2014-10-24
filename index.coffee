os = require 'os'
_ = require 'lodash'


# Returns a {String}
detectPlatform = ->
    platforms =
        darwin: -> 'osx'
        win: -> 'win'
        linux: -> 'linux' + if process.arch is 'ia32' then 32 else 64

    return platforms[os.platform()]

# args - {Object}
#       :options - {Object} or {String}, depending on the `objectMode` parameter
#       :platform - Optional {String}. One of the following: [osx, win, linux32, linux64]. If not passed, current
#                   platform is detected
#       :objectMode - Optional {Boolean}. If `true`, `options` will have to passed as an {Object} and the return value
#                    will be an {Object} too
# Returns an {String} or {Object}, depending on `objectMode` parameter
module.exports = (args) ->
    platform = if args.platform then args.platform else detectPlatform()

    objectMode = args.objectMode
    options = if objectMode then args.options else JSON.parse args.options

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

        return if objectMode then result else JSON.stringify result
    else
        return args.options
