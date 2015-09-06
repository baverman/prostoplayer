export fetch = (url, params, cb) ->
    host = if window.cordova
           then 'http://zvooq.ru'
           else 'http://localhost:3001'

    data <- window.jQuery.getJSON host + url, params
    cb data?.result
