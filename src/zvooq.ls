jq = require 'jquery'


export fetch = (url, params, cb) ->
    host = if window._CORS
           then 'http://localhost:3000'
           else 'http://zvooq.ru'

    data <- jq.getJSON host + url, params
    cb data?.result
