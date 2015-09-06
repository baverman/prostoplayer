React = require 'react/addons'

require './style/track-list.styl'
{format-seconds} = require './utils.ls'


module.exports = React.create-class do
    mixins: [React.addons.PureRenderMixin]

    context-types:
        app: React.PropTypes.object
        meta: React.PropTypes.object

    get-initial-state: ->
        loaded: false

    play: (pos) !->
        @context.app.play @props.tracks, pos

    render: ->
        @context.meta.ensure tracks: @props.tracks, ~>
            if it
                @state.loaded = true
            else
                @set-state loaded: true

        pos = 0
        $div class-name: \track-list,
            for tid in @props.tracks
                pos++
                track = @context.meta.tracks[tid]
                if track then
                    $div do
                        class-name: \track-list-item
                        on-click: @play.bind null, pos - 1
                        $span class-name: \pos, "#{track.position}."
                        $span class-name: \title, track.title
                        $span class-name: \duration, format-seconds track.duration
                else
                    $div class-name: \track-list-item,
                        $span class-name: \pos, "#{pos}."
                        $span class-name: \title, tid
                        $span class-name: \duration, '0:00'
