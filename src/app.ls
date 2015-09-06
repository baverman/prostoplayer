React    = require 'react/addons'
contains = require 'lodash/collection/contains'
merge    = require 'lodash/object/merge'
cn       = require 'classnames'
mui =
    Styles: require 'material-ui/lib/styles'
    AppBar: require 'material-ui/lib/app-bar'
    IconButton: require 'material-ui/lib/icon-button'
    Icons:
        Menu: require 'material-ui/lib/svg-icons/navigation/menu'
        Left: require 'material-ui/lib/svg-icons/navigation/chevron-left'

do require 'react-tap-event-plugin'

require './style/app.styl'
{children} = require './utils.ls'
Meta       = require './meta.ls'
Mobscreen  = require './mobscreen.ls'
Release    = require './release.ls'
{Player, PlayerWidget}   = require './player.ls'

window.$ = React.create-element
window.$$ = React.create-factory
for key, value of React.DOM
    window."$#key" = value

theme-manager = new mui.Styles.ThemeManager!
meta-store = new Meta!


Page = React.create-class do
    mixins: [React.addons.PureRenderMixin]

    context-types:
        app: React.PropTypes.object

    nav-button: ->
        if @props.first
        then $ mui.IconButton, null, $ mui.Icons.Menu
        else $ mui.IconButton,
            on-click: @context.app.back
            $ mui.Icons.Left

    render: ->
        class-name = cn do
            'page-with-player': @props.player.current
            'top-page': @props.active
            'page': not @props.active

        $div class-name: class-name, children do
            $div class-name: 'app-bar', key: \menu,
                $ mui.AppBar,
                    title: @props.title
                    icon-element-left: @nav-button!

            $div class-name: 'page-content', key: \content,
                $ @props.content, merge do
                    pkey: @props.pkey
                    data: @props.data
                    mutator: views-mutator
                    @props.props


App = $$ React.create-class do
    mixins: [React.addons.PureRenderMixin]

    child-context-types:
        mui-theme: React.PropTypes.object
        app: React.PropTypes.object
        meta: React.PropTypes.object

    get-child-context: ->
        mui-theme: theme-manager.get-current-theme!
        app: @
        meta: meta-store

    get-initial-state: ->
        data: @props.data

    add: (view, props, apply-view-data) !->
        pages = @state.data.pages ++ [[view, props]]
        app-data-mutator React.addons.update @state.data,
            pages: $set: pages
            # views: if apply-view-data then
            #      (views[view].id props): $apply: apply-view-data

    back: !->
        pages = @state.data.pages[0 til -1]
        app-data-mutator React.addons.update @state.data,
            pages: $set: pages

    play: (tracks, idx) ->
        @props.player.play tracks, idx

    play-pause: ->
        @props.player.play-pause!

    make-page: (page, active, first) ->
        [view, props] = page
        v = views[view]
        key = v.id props
        title = v.title props
        $ Page,
            key: key
            first: first
            active: active
            title: title
            content: v.component
            pkey: key
            data: @state.data.views[key]
            props: props
            player: @state.data.player

    render: ->
        [...ipages, apage] = @state.data.pages
        cnt = 0
        $div class-name: \full, children do
            for page in ipages
                @make-page page, false, not cnt++
            @make-page apage, true, not cnt
            if @state.data.player
                $ PlayerWidget, key: \player-widget, data: @state.data.player


views = do
    mobscreen:
        component: Mobscreen
        id: -> \mobscreen
        title: -> \Zplayer
    release:
        component: Release
        id: (props) -> "release-#{props.id}"
        title: -> \Release
    playlist:
        component: Release
        id: (props) -> "playlist-#{props.id}"
        title: -> \Playlist


player = new Player !->
    app-data-mutator React.addons.update app-data, player: $apply: it


app-data = do
    version: 4
    views:
        mobscreen:
            tabs: {}
    pages: []
    player: player.get-initial-data!


app-data-mutator = (it, update-hash=true)->
    console.log 'Data', it
    # console.trace!
    app-data := it
    hash.set! if update-hash
    localStorage['app-data'] = JSON.stringify app-data
    app.set-state data:it


views-mutator = (key, value) ->
    app-data-mutator React.addons.update app-data, views: (key): $set: value


get-current-pages = ->
    pages = if location.hash
            then location.hash |> (.slice 1) |> decodeURI |> JSON.parse
            else []

    if not pages?.length
    then [['mobscreen', null]]
    else pages


hash =
    set: !->
        @.off!
        location.hash = app-data.pages |> JSON.stringify |> encodeURI
        @.on!

    handle: !->
        app-data-mutator do
            React.addons.update do
                app-data
                pages: $set: get-current-pages!
            false
        it.prevent-default!
        it.stop-propagation!

    on: !->
       window.addEventListener 'hashchange' @handle

    off: !->
       window.removeEventListener 'hashchange' @handle


if not location.search `contains` 'force=1'
    stored-data = localStorage['app-data']
    if stored-data
        stored-data = JSON.parse stored-data
        if stored-data.version == app-data.version
            app-data = stored-data
            app-data.player.state = \stop
            if location.hash
                app-data.pages = get-current-pages!

if not app-data?.pages?.length
    app-data.pages = get-current-pages!

hash.set!

app = React.render do
    App data: app-data, player: player
    document.get-element-by-id 'app-window'

document.addEventListener 'backbutton', app.back, false
