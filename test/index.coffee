platformOverrides = require '../index.coffee'
chai = require 'chai'
expect = chai.expect
fs = require 'fs'
path = require 'path'
os = require 'os'

getFixture = (pathSegment) ->
    fs.readFileSync(path.join './test/fixtures/', pathSegment).toString()
getExpected = (pathSegment, basename) ->
    fs.readFileSync(path.join './test/expected/', pathSegment, basename + '.json').toString()


describe 'platform-overrides', ->
    it 'should apply overrides correctly for each platform', ->
        for platform in ['osx32', 'osx64', 'win32', 'win64', 'linux32', 'linux64']
            args =
                options: getFixture 'all/package.json'
                platform: platform

            platformOverrides args, (err, result) ->
                expect(result).to.be.a 'string'
                expect(JSON.parse result).to.deep.equal JSON.parse getExpected 'all', platform

    it 'should apply windows overrides if os.platform() returns win32 / win64', ->
        for platform in ['win32', 'win64']
            args =
                options: getFixture 'all/package.json'
                platform: platform

            platformOverrides args, (err, result) ->
                expect(result).to.be.a 'string'
                expect(JSON.parse result).to.deep.equal JSON.parse getExpected 'all', 'win32'

    it 'should support passing an object and then return an object', ->
        for platform in ['osx32', 'osx64', 'win32', 'win64', 'linux32', 'linux64']
            args =
                options: JSON.parse getFixture 'all/package.json'
                platform: platform

            platformOverrides args, (err, result) ->
                expect(result).to.be.an 'object'
                expect(result).to.deep.equal JSON.parse getExpected 'all', platform

    it 'should support not passing a platform (auto-detect)', ->
        # If a manifest contains overrides for every platform, then the result shouldn't just be the base options

        args =
            options: JSON.parse getFixture 'all/package.json'

        platformOverrides args, (err, result) ->
            expect(result).to.be.an 'object'
            expect(result).not.to.deep.equal JSON.parse getExpected 'all', 'none'


    it 'should apply overrides correctly for appropriate platforms and strip platformOverrides regardless', ->
        for platform in ['osx32', 'osx64', 'win32', 'win64', 'linux32', 'linux64']
            args =
                options: getFixture 'oneOveriddenRestNot/package.json'
                platform: platform

            platformOverrides args, (err, result) ->
                expect(JSON.parse result).to.deep.equal JSON.parse getExpected(
                    'oneOveriddenRestNot',
                    if platform is 'osx32' then platform else 'rest'
                )

    it 'should leave file as is if platformOverrides does not exist', ->
        for platform in ['osx32', 'osx64', 'win32', 'win64', 'linux32', 'linux64']
            contents = getFixture 'none/package.json'
            args =
                options: contents
                platform: platform

            platformOverrides args, (err, result) ->
                expect(result).to.equal contents


    it 'should apply overrides while giving precedence to specificity', ->
        for platform in ['osx32', 'osx64', 'win32', 'win64', 'linux32', 'linux64']
            args =
                options: getFixture 'specificity/package.json'
                platform: platform

            platformOverrides args, (err, result) ->
                expect(JSON.parse result).to.deep.equal JSON.parse getExpected('specificity', platform)


    it 'should fall back to general platform override if platform with architecture is passed but no archecture-level overrides exist', ->
        for platform in ['osx32', 'osx64', 'win32', 'win64', 'linux32', 'linux64']
            args =
                options: getFixture 'fallBackToPlatform/package.json'
                platform: platform

            platformOverrides args, (err, result) ->
                expect(JSON.parse result).to.deep.equal JSON.parse getExpected('fallBackToPlatform', platform)


    it 'should ignore architecture-level overrides if architecture-agnostic platform is passed', ->
        for platform in ['osx', 'win', 'linux']
            args =
                options: getFixture 'architectureAgnostic/package.json'
                platform: platform

            platformOverrides args, (err, result) ->
                expect(JSON.parse result).to.deep.equal JSON.parse getExpected('architectureAgnostic', platform)

    it 'should always use architecture-level overrides when auto-detecting platform', ->
        args =
            options: getFixture 'autodetectingArchitecture/package.json'

        actualPlatform = os.platform()
        if actualPlatform is 'darwin'
            actualPlatform = 'osx'
        else if actualPlatform.match /^win/
            actualPlatform = 'win'

        platformOverrides args, (err, result) ->
            expect(JSON.parse result).to.deep.equal JSON.parse getExpected(
                'autodetectingArchitecture',
                actualPlatform + if process.arch is 'x64' or process.env.hasOwnProperty('PROCESSOR_ARCHITEW6432') then 64 else 32
            )

    it 'should throw error if invalid platform is passed', ->
        args =
            options: getFixture 'autodetectingArchitecture/package.json'
            platform: 'nah'

        platformOverrides args, (err, result) ->
            expect(err instanceof Error).to.equal true
            expect(err.message).to.equal 'Invalid platform passed'
            expect(result).to.equal null

    it 'should return an error if invalid JSON is passed', ->
        args =
            options: '{a:0'

        platformOverrides args, (err, result) ->
            expect(err instanceof Error).to.equal true
            expect(result).to.equal null