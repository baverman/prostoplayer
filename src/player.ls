React = require 'react/addons'
Paper = require 'material-ui/lib/paper'
mui =
    IconButton: require 'material-ui/lib/icon-button'
    Icons:
        Play: require 'material-ui/lib/svg-icons/av/play-arrow'
        Pause: require 'material-ui/lib/svg-icons/av/pause'

require './style/player.styl'
{fetch}    = require './zvooq.ls'
{children} = require './utils.ls'


get-track-url = (track-id, cb) ->
    result <- fetch "/api/track/#{track-id}/stream_url"
    cb result?.result


export class Player
    (mutator) ->
        @mutator = mutator
        @audio = new Audio!
        @audio.addEventListener 'ended', ~>
            @play @tracks, @idx + 1

    get-initial-data: ->
        state: \stop
        current: null
        idx: null
        queue: []

    play: (tracks, idx) ->
        @tracks = tracks
        @idx = idx
        src <~ get-track-url tracks[idx]
        @audio.src = src
        @audio.play!
        @mutator ->
            state: \play
            current: tracks[idx]
            idx: idx
            queue: tracks

    play-pause: !->
        @mutator (cur) ~>
            if cur.state == \play
                @audio.pause!
                React.addons.update cur, state: $set: \pause
            else if cur.state == \pause
                @audio.play!
                React.addons.update cur, state: $set: \play
            else
                set-timeout do
                    ~> @play cur.queue, cur.idx
                    0
                cur


export PlayerQueue = React.create-class do
    render: ->


export PlayerWidget = React.create-class do
    mixins: [React.addons.PureRenderMixin]

    context-types:
        meta: React.PropTypes.object
        app: React.PropTypes.object

    get-initial-state: ->
        loaded: false

    render: ->
        @context.meta.ensure tracks: @props.data.queue, ~>
            if it
                @state.loaded = true
            else
                @set-state loaded: true

        $div class-name: \player-widget,
            $ Paper,
                z-depth: 2
                style:
                    width: '100%'
                    height: '100%'
                if @state.loaded
                    track = @context.meta.tracks[@props.data.current]
                    release = @context.meta.releases[track.release_id]
                    $div class-name: \inner,
                        $div do
                            class-name: \cover
                            style:
                                background-image: "url(#{release.image.src.replace('{size}', '64x64')})"
                        $div class-name: \content,
                            track.title
                            $br!
                            $span do
                                style:
                                    font-size: 12px
                                track.credits
                        $div class-name: \button,
                            $ mui.IconButton,
                                on-click: ~> @context.app.play-pause!
                                if @props.data.state == 'play'
                                    $ mui.Icons.Pause
                                else
                                    $ mui.Icons.Play
                else
                    'Loading...'
