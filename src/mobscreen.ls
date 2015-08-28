React = require 'react/addons'
{unique, map} = require 'prelude-ls'
{random, isEmpty} = require 'lodash'
{RefreshIndicator} = require 'material-ui'

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


Release = React.create-class do
    render: ->
        img_url = @props.release.image.src.replace('{size}', '300x300')
        style =
            background-image: "url('#img_url')"
            background-size: \cover
        $a class-name: \release, style: style, href: "#/release/#{@props.release.id}"


Playlist = React.create-class do
    render: ->
        style =
            background-image: "url('http://zvooq.ru#{@props.playlist.image_url}')"
            background-size: \cover
        $a class-name: \playlist, style: style, href: "#/playlist/#{@props.playlist.id}"


export Mobscreen = React.create-class do
    get-initial-state: ->
        data: null

    component-will-mount: ->
        data <~ get-mobscreen @props.tab
        @set-state data: data

    render: ->
        if not @state.data
            return $ RefreshIndicator, do
                size: 40
                status: "loading"
                style:
                    left: '50%'
                    margin-left: -20px
                    top: 20px

        $div class-name: 'mobscreen scrollable', for cell in @state.data
            $div class-name: \aspect-2x1,
                $div class-name: \with-aspect, for r in cell
                    if r.item_type == \release
                        $ Release, release: r.object
                    else if r.item_type == \playlist
                        $ Playlist, playlist: r.object
