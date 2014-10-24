platformOverrides = require '../'
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
        for platform in ['mac', 'win', 'linux32', 'linux64']
            result = platformOverrides
                options: getFixture 'all/package.json'
                platform: platform

            expect(result).to.be.a 'string'
            expect(JSON.parse result).to.deep.equal JSON.parse getExpected 'all', platform

    it 'should support passing and returning objects', ->
        for platform in ['mac', 'win', 'linux32', 'linux64']
            result = platformOverrides
                options: JSON.parse getFixture 'all/package.json'
                platform: platform
                objectMode: true

            expect(result).to.be.an 'object'
            expect(result).to.deep.equal JSON.parse getExpected 'all', platform

    it 'should support not passing a platform', ->
        platformOverrides
            options: JSON.parse getFixture 'all/package.json'
            objectMode: true

    it 'should apply overrides correctly for appropriate platforms and strip platformOverrides regardless', ->
        for platform in ['mac', 'win', 'linux32', 'linux64']
            result = platformOverrides
                options: getFixture 'oneOveriddenRestNot/package.json'
                platform: platform

            expect(JSON.parse result).to.deep.equal JSON.parse getExpected(
                'oneOveriddenRestNot',
                if platform is 'mac' then platform else 'rest'
            )

    it 'should leave file as is if platformOverrides does not exist', ->
        for platform in ['mac', 'win', 'linux32', 'linux64']
            contents = getFixture 'none/package.json'

            result = platformOverrides
                options: contents
                platform: platform

            expect(result).to.equal contents