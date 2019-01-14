os = require 'os'
_ = require 'lodash'

# Returns an {Object}
detectPlatform = ->
    platform = os.platform()
    if platform is 'darwin'
        platform = 'osx'
    else if platform.match /^win/
        platform = 'win'

    return {
        agnostic: platform
        specific: platform + if process.arch is 'x64' or process.env.hasOwnProperty('PROCESSOR_ARCHITEW6432') then 64 else 32
    }

# platform - Optional {String}
# cb - {Function}
# Returns an {Object}
getOverridesToApply = (platform, cb) ->
    architectureAgnostic = ['linux', 'osx', 'win']
    architectureSpecific = []
    for agnosticPlatform in architectureAgnostic
        architectureSpecific.push agnosticPlatform + '32'
        architectureSpecific.push agnosticPlatform + '64'

    if platform
        unless architectureAgnostic.indexOf(platform) > -1 or architectureSpecific.indexOf(platform) > -1
            return cb new Error 'Invalid platform passed', null

        if architectureAgnostic.indexOf(platform) > -1
            cb null, {
                agnostic: platform
                specific: null
            }
        else
            # e.g. win and win64
            cb null, {
                agnostic: platform.substr 0, platform.length - 2
                specific: platform
            }
    else
        cb null, detectPlatform()

# args - {Object}
#       :platform - {String}
#       :options - {Object}
#       :cb - {Function}, called with the result as the only argument
applyOverrides = ({platform, options, cb}) ->

    result = _.cloneDeep options
    if options.platformOverrides[platform]? and Object.keys(options.platformOverrides[platform]).length
        result = _.mergeWith(
            result,
            options.platformOverrides[platform],
            (optionValue, overrideValue) ->
                ###
                  If overrides.x is {} but source.x is a non-empty object {prop:0, another:2},
                  take the {}}
                ###
                overrideValue if (_.isPlainObject(overrideValue) or  _.isArray overrideValue) and  _.isEmpty overrideValue
        )

    cb result

# args - {Object}
#       :options - {Object} or {String}
#       :platform - Optional {String}. One of the following: [osx, osx32, osx64, win, win32, win64, linux, linux32, linux64]. If not passed, current
#                   platform is detected
# cb - {Function}. Called with Error and result arguments
# Returns an {String} or {Object}, depending on `objectMode` parameter
module.exports = ({options, platform}, cb) ->

    callback = if cb? then cb else (->)
    getOverridesToApply platform, (err, overridesToApply) ->
        return callback err, null if err?

        originalOptions = options
        objectMode = _.isPlainObject options

        try
            options = if objectMode then options else JSON.parse options
        catch err
            return callback err, null



        if options.platformOverrides?

            applySpecificOverrides = (optionsToOverride) ->
                applyOverrides
                    platform: overridesToApply.specific
                    options: optionsToOverride
                    cb: (result) ->
                        delete result.platformOverrides
                        callback null, if objectMode then result else JSON.stringify result

            if overridesToApply.agnostic?
                applyOverrides
                    platform: overridesToApply.agnostic
                    options: options
                    cb: (result) ->
                        if overridesToApply.specific?
                            applySpecificOverrides result
                        else
                            delete result.platformOverrides
                            callback null, if objectMode then result else JSON.stringify result
            else
                applySpecificOverrides options
        else
            callback null, originalOptions
