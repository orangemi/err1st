Err = require '../lib/err1st.js'
en = require './en'
zh = require './zh'

Err.meta SOMETHING_WRONG: 500100
Err.localeMeta 'zh', 'message', zh
Err.localeMeta 'en', 'message', en

err = new Err('SOMETHING_WRONG', 'Alice')

throw err
throw err.locale('en')
