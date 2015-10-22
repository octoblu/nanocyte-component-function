ReturnValue = require 'nanocyte-component-return-value'
Function = require '../src/function'

describe 'Function', ->
  beforeEach ->
    @sut = new Function

  it 'should exist', ->
    expect(@sut).to.be.an.instanceOf ReturnValue

  describe '->onEnvelope', ->
    describe 'when given the func', ->
      it 'should func it up', ->
        envelope =
          config:
            func: 'return 5;'

        expect(@sut.onEnvelope envelope).to.deep.equal 5

    describe 'when given the uptown func', ->
      it 'should uptown func it up', ->
        envelope =
          config:
            func: 'return {"uptown": "func"};'

        expect(@sut.onEnvelope envelope).to.deep.equal uptown: "func"

    describe 'when doing things it shouldnt', ->
      it 'should raise an error', ->
        envelope =
          config:
            func: 'return process.exit(1);'

        expect(=> @sut.onEnvelope envelope).to.throw 'process is not defined'

    describe 'when using lodash', ->
      it 'should provide lodash', ->
        envelope =
          config:
            func: 'return _.first([1,2,3]);'

        expect(@sut.onEnvelope envelope).deep.equal 1

  describe 'when a malicious function mutates lodash', ->
    beforeEach ->
      envelope =
        config:
          func: '_.foo = 3;'

      @sut.onEnvelope envelope

    describe 'when a second instance is instantiated', ->
      beforeEach ->
        @sut2 = new Function

      it 'should not have a mutated lodash', ->
        envelope =
          config:
            func: 'return _.foo;'

        expect(@sut2.onEnvelope envelope).to.be.undefined

  describe 'when a malicious function mutates moment', ->
    beforeEach ->
      envelope =
        config:
          func: 'moment.foo = 3;'

      @sut.onEnvelope envelope

    describe 'when a second instance is instantiated', ->
      beforeEach ->
        @sut2 = new Function

      it 'should not have a mutated lodash', ->
        envelope =
          config:
            func: 'return moment.foo;'

        expect(@sut2.onEnvelope envelope).to.be.undefined

  describe 'when a malicious function mutates tinycolor', ->
    beforeEach ->
      envelope =
        config:
          func: 'tinycolor.foo = 3;'

      @sut.onEnvelope envelope

    describe 'when a second instance is instantiated', ->
      beforeEach ->
        @sut2 = new Function

      it 'should not have a mutated lodash', ->
        envelope =
          config:
            func: 'return tinycolor.foo;'

        expect(@sut2.onEnvelope envelope).to.be.undefined

  describe 'when a clever malicious function mutates lodash', ->
    beforeEach ->
      envelope =
        config:
          func: '_.first.foo = 3;'

      @sut.onEnvelope envelope

    describe 'when a second instance is instantiated', ->
      beforeEach ->
        @sut2 = new Function

      it 'should not have a mutated lodash', ->
        envelope =
          config:
            func: 'return _.first.foo;'

        expect(@sut2.onEnvelope envelope).to.be.undefined

  describe 'when a malicious function hogs the CPU', ->
    it 'should terminate the execution by throwing', ->
      envelope =
        config:
          func: 'while(true){};'

      expect(=> @sut.onEnvelope envelope).to.throw

  describe 'when the function returns a null', ->
    it 'should not send the message through', ->
      envelope =
        config:
          func: 'return null'


      expect(@sut.onEnvelope envelope).to.not.exist
