jq = require 'jquery'


export fetch = (url, params, cb) ->
    host = if window.cordova
           then 'http://zvooq.ru'
           else 'http://localhost:3001'

    data <- jq.getJSON host + url, params
    cb data?.result
