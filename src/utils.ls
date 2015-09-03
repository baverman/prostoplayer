size     = require 'lodash/collection/size'
is-array = require 'lodash/lang/isArray'


export children = (...args) ->
    result = []
    for arg in args
        if is-array arg
            result.push ...arg
        else if arg
            result.push arg

    return result


export parallel = (tasks, done) !->
    result = {}
    cnt = size tasks
    for own let name, fn of tasks
        result[name] <-! fn!
        cnt--
        done result if not cnt


export format-seconds = (secs) ->
    minutes = Math.floor(secs/60)
    secs = secs % 60
    if secs < 10
        secs = '0' + secs.to-string!
    return "#minutes:#secs"
