platformOverrides = require '../index.coffee'
chai = require 'chai'
expect = chai.expect
fs = require 'fs'
path = require 'path'

getFixture = (pathSegment) ->
    fs.readFileSync(path.join './test/fixtures/', pathSegment).toString()
getExpected = (pathSegment, basename) ->
    fs.readFileSync(path.join './test/expected/', pathSegment, basename + '.json').toString()


describe 'platform-overrides', ->
    it 'should apply overrides correctly for each platform', ->
        for platform in ['osx', 'win', 'linux32', 'linux64']
            args =
                options: getFixture 'all/package.json'
                platform: platform

            platformOverrides args, (err, result) ->
                expect(result).to.be.a 'string'
                expect(JSON.parse result).to.deep.equal JSON.parse getExpected 'all', platform

    it 'should support passing an object and then return an object', ->
        for platform in ['osx', 'win', 'linux32', 'linux64']
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
        for platform in ['osx', 'win', 'linux32', 'linux64']
            args =
                options: getFixture 'oneOveriddenRestNot/package.json'
                platform: platform

            platformOverrides args, (err, result) ->
                expect(JSON.parse result).to.deep.equal JSON.parse getExpected(
                    'oneOveriddenRestNot',
                    if platform is 'osx' then platform else 'rest'
                )

    it 'should leave file as is if platformOverrides does not exist', ->
        for platform in ['osx', 'win', 'linux32', 'linux64']
            contents = getFixture 'none/package.json'
            args =
                options: contents
                platform: platform

            platformOverrides args, (err, result) ->
                expect(result).to.equal contents

    it 'should return an error if invalid JSON is passed', ->
        args =
            options: '{a:0'

        platformOverrides args, (err, result) ->
            expect(err instanceof Error).to.equal true
            expect(result).to.equal null