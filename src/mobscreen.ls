React = require 'react/addons'
{unique, map} = require 'prelude-ls'
{random, isEmpty} = require 'lodash'
{RefreshIndicator} = require 'material-ui'
Swipeable = require 'react-swipeable'

{fetch} = require './zvooq.ls'
require './mobscreen.styl'

tabs = 1: \small_wtl

fetch-item = (cell, lists) ->
    ilist = lists[cell.item]
    if isEmpty ilist
        return

    if cell.type == \random
        ilist.splice(random(ilist.length - 1), 1)[0]
    else if cell.type == \linear
        ilist.splice(0, 1)[0]
    else
        console.log cell.type


get-mobscreen = (tab, cb) ->
    grid <- fetch '/api/featured/', name: tabs[tab]
    items = [r for r in grid.list
               when \item of r and \custom_block not of r]

    ids = unique [r.item for r in items]
    lists <- fetch '/api/layout_by_ids', ids: ids.join(\,)
    cells = []
    cell = []
    size = 0
    for it in items
        for _ in [1 to it.repeat or 1]
            if size + it.size_x > 2
                cells.push(cell)
                cell = []
                size = 0
            object = fetch-item it, lists
            size += it.size_x
            cell.push(object) if object

    cells.push(cell) if not isEmpty cell

    rids = [r.id for cell in cells
                 for r in cell
                 when r.item_type == \release]

    pids = [r.id for cell in cells
                 for r in cell
                 when r.item_type == \playlist]

    releases <- fetch '/api/tiny/releases', ids: rids.join(\,)
    playlists <- fetch '/api/tiny/playlists', ids: pids.join(\,)
    for cell in cells
        for r in cell
            if r.item_type == \release
                r.object = releases.releases[r.id]
            else if r.item_type == \playlist
                r.object = playlists.playlists[r.id]

    cb(cells)


gradient = 'linear-gradient(to bottom, rgba(0, 0, 0, 0), rgba(0, 0, 0, 0.7))'


Release = React.create-class do
    context-types:
        app: React.PropTypes.object

    render: ->
        img_url = @props.release.image.src.replace('{size}', '300x300')
        $div do
            class-name: \release
            style:
                background-image: "#gradient, url('#img_url')"
                background-size: \cover
            onClick: ~> @context.app.add do
                \release
                id: @props.release.id,
            $div class-name: \bottom,
                @props.release.title
                $br!
                @props.release.credits


Playlist = React.create-class do
    context-types:
        app: React.PropTypes.object

    render: ->
        $a do
            class-name: \playlist
            style:
                background-image: "#gradient, url('http://zvooq.ru#{@props.playlist.image_url}')"
                background-size: \cover
            onClick: ~> @context.app.add do
                \playlist
                id: @props.playlist.id
            $div class-name: \bottom,
                @props.playlist.title


export Mobscreen = React.create-class do
    mixins: [React.addons.PureRenderMixin]

    get-initial-state: ->
        fetching-data: false
        pull: false

    pull-to-refresh: (e, delta) !->
        if React.findDOMNode(@refs.scroll).scrollTop <= 0
            status = React.findDOMNode @refs.status
            if status
                scale = Math.min(1, delta / 100)
                status.style.transform = "scale(#scale)"
            else
                @set-state pull: true, tend: true

            return true

    pull-to-refresh-done: (e, delta) !->
        if React.findDOMNode(@refs.scroll).scrollTop > 0
            return

        if delta < -100 and !@state.fetching-data
            @set-state fetching-data: true, pull: false
            data <~ get-mobscreen 1
            @state.fetching-data = false
            @props.mutator @props.pkey, tabs: 1: data

    render: ->
        console.log 'Render'
        if not @props.data.tabs.1
            data <~ get-mobscreen 1
            @props.mutator @props.pkey, tabs: 1: data

        $ Swipeable,
            class-name: \full
            on-swiping-down: @pull-to-refresh
            on-swiped-down: @pull-to-refresh-done
            $div class-name: 'mobscreen scrollable', ref: \scroll,
                if @state.fetching-data or @state.pull or !@props.data.tabs.1
                    $ RefreshIndicator, do
                        ref: 'status'
                        size: 40
                        status: 'loading'
                        style:
                            left: '50%'
                            margin-left: -20px
                            top: 20px
                            transform: if @state.pull then 'scale(0)' else 'scale(1.0)'
                for cell in @props.data.tabs.1
                    $div class-name: \aspect-2x1,
                        $div class-name: \with-aspect, for r in cell
                            if r.item_type == \release
                                $ Release, release: r.object
                            else if r.item_type == \playlist
                                $ Playlist, playlist: r.object
