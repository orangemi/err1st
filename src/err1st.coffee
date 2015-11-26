util = require 'util'

_parseMeta = (meta) ->
  if toString.call(meta) is '[object Object]'
    _meta = meta

  else if /^-?[0-9]+$/.test meta
    status = Number(String(meta)[0...3])
    code = Number(String(meta)[3...])
    _meta = status: status, code: code

  else if toString.call(meta) is '[object String]' or toString.call(meta) is '[object Function]'
    _meta = message: meta

  else if toString.call(meta) is '[object Array]'
    _meta = meta.reduce (meta, cur) ->
      _cur = _parseMeta(cur)
      meta[key] = val for key, val of _cur
      meta
    , {}

  else _meta = {}

  _meta

Err1st = (phrase, params...) ->
  if phrase instanceof Err1st
    return phrase

  if phrase instanceof Error
    if phrase.stack
      Object.defineProperty this, 'stack',
        value: phrase.stack
        writable: true
    else
      Error.captureStackTrace(this, arguments.callee)

    @phrase = phrase.phrase or 'unknown_error'
    @params = phrase.params
    _meta = util._extend
      code: phrase.code
      status: phrase.status
      message: phrase.message
    , @constructor._meta[@phrase] or {}
  else
    @phrase = phrase
    @params = params
    Error.captureStackTrace(this, arguments.callee)
    _meta = @constructor._meta[phrase] or {}

  Object.defineProperty this, 'meta',
    get: ->
      return _meta unless _meta._locales
      # Use the first key as default language
      @_lang or= Object.keys(_meta._locales)[0]
      _meta = util._extend _meta, _meta._locales[@_lang]
      _meta
  Object.defineProperty this, 'code', get: -> @meta.code or 100
  Object.defineProperty this, 'status', get: -> @meta.status or 500
  Object.defineProperty this, 'message', get: ->
    if toString.call(@meta.message) is '[object Function]'
      @meta.message.apply this, @params
    else
      _args = [].concat [@meta.message or @phrase], (@params or [])
      util.format.apply util, _args

  this

Err1st.prototype.__proto__ = Error.prototype

Err1st.prototype.name = 'Err1st'

Err1st.prototype.toJSON =  ->
  status: @status
  code: @code
  message: @message

Err1st.prototype.locale = (@_lang) -> this

Err1st._meta = unknown_error: code: 100, status: 500

Err1st.meta = (meta) ->
  for phrase, _meta of meta
    @_meta[phrase] or= {}
    _meta = _parseMeta _meta
    @_meta[phrase][key] = val for key, val of _meta
  @_meta

Err1st.localeMeta = (lang, meta) ->
  for phrase, _meta of meta
    @_meta[phrase] or= {}
    @_meta[phrase]._locales or= {}
    _locales = @_meta[phrase]._locales[lang] or {}
    _meta = _parseMeta _meta
    _locales[key] = val for key, val of _meta
    @_meta[phrase]._locales[lang] = _locales
  @_meta

module.exports = Err1st
