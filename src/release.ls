React = require 'react/addons'

require './release.styl'
TrackList  = require './track-list.ls'
{children} = require './utils.ls'


module.exports = React.create-class do
    mixins: [React.addons.PureRenderMixin]

    context-types:
        meta: React.PropTypes.object

    get-initial-state: ->
        loaded: false

    render: ->
        @context.meta.ensure releases: [@props.id], ~>
            if it
                @state.loaded = true
            else
                @set-state loaded: true

        $div class-name: "release-view scrollable", children do
            if @state.loaded
                console.log @context.meta.releases
                release = @context.meta.releases[@props.id]
                img_url = release.image.src.replace '{size}' '500x500'
                result =
                    $div class-name: \aspect-1x1,
                        $div class-name: \with-aspect,
                            $div do
                                class-name: 'full cover'
                                style:
                                    background-image: "url(#img_url)"
                                    background-size: \cover
                                $div class-name: \cover-plate,
                                    $span class-name: \title, release.title
                                    $br!
                                    $span class-name: \credits, release.credits
                                    $br!
                                    $span class-name: \info, release.date.to-string().slice(0, 4)
                    $ TrackList, tracks: release.track_ids
