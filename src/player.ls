React    = require 'react/addons'

{fetch} = require './zvooq.ls'


get-track-url = (track-id, cb) ->
    result <- fetch "/api/track/#{track-id}/stream_url"
    cb result?.result


export class Player
    (mutator) ->
        @mutator = mutator
        @audio = new Audio!

    get-initial-data: ->
        state: \stop
        current: null
        idx: null
        queue: []

    play: (tracks, idx) ->
        src <~ get-track-url tracks[idx]
        @audio.src = src
        @audio.play!
        @mutator ->
            state: \play
            current: tracks[0]
            idx: idx
            queue: tracks


export PlayerQueue = React.create-class do
    render: ->


export PlayerWidget = React.create-class do
    render: ->
