should = require('should')
Err = require('../lib')
{handler} = require('../lib')

describe 'handler', ->

  describe 'handler#validate', ->

    it 'should format map in the correct data structure', ->
      handler.validate ->
        @map =
          DB_ERROR: [500101, '数据库错误']
        handler.map.DB_ERROR.code.should.be.eql(500101)

    it 'should accept non-object map', ->
      handler.validate ->
        @map =
          NO_OBJECT: 674621
        handler.map.NO_OBJECT.code.should.be.eql(674621)

  describe 'handler#parse', ->

    it 'should parse the correct message', ->

      handler.validate ->
        @map =
          UPDATE_ERROR: [
            500102,
            (field) ->
              "#{field} 更新错误"
          ]

      err = new Err('UPDATE_ERROR', 'name')
      err = handler.parse(err)
      err.toMsg().should.be.eql('name 更新错误')

    it 'should parse the correct message in English', ->

      handler.validate ->
        @localeDir = "#{__dirname}/locales"
        @locales = ['en', 'zh']
        @map =
          LANG_ERROR: [500201]

        err = new Err('LANG_ERROR', 'Jerry')
        err = handler.parse(err)
        err.toMsg().should.be.eql("Hello Jerry, You've got an error")
        errZh = handler.parse(err, {lang: 'zh'})
        errZh.toMsg().should.be.eql('你好 Jerry, 你得到了一个错误')

    it 'should parse the string typed error', ->

      handler.validate ->
        @map =
          STRING_ERROR: [123455, 'something wrong']
        handler.parse('STRING_ERROR').toMsg().should.be.eql("something wrong")

    it 'should use default err when not defined', ->
      handler.parse('undefined').toMsg().should.be.eql('Unknown Error')

  describe 'handler#customErrorName', ->

    it 'should have custom error name', ->

      _handler = new handler.Handler
      _handler.validate ->
        @name = 'CustomError'
        @map =
          UPDATE_ERROR: [500102, "更新错误"]

        err = new Err("UPDATE_ERROR")
        _handler.parse(err).toString().should.be.eql('CustomError: 更新错误')
