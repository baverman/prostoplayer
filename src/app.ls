React = require 'react/addons'
window.$ = React.create-element
window.$$ = React.create-factory
for key, value of React.DOM
    window."$#key" = value

(require 'react-tap-event-plugin')!

{split-at} = require 'prelude-ls'
cn = require 'classnames'
mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()

require './app.styl'
{Mobscreen} = require './mobscreen.ls'

window._CORS = \cordova not of window


Page = React.create-class do
    render: ->
        class-name = cn do
            'with-app-bar': true
            'top-page': @props.active
            'page': !@props.active
        $div class-name: class-name, @props.children


Release = React.create-class do
    render: ->
        $div null, \Boo


App = $$ React.create-class do
    mixins: [React.addons.PureRenderMixin]

    child-context-types:
        mui-theme: React.PropTypes.object
        app: React.PropTypes.object

    get-child-context: ->
        self = @
        do
            mui-theme: ThemeManager.get-current-theme!
            app: self

    get-initial-state: ->
        data: @props.data

    add: (view, props) ->
        pages = @state.data.pages.concat [[view, props]]
        pages-mutator pages

    make-page: (view, props, is-active) ->
        v = views[view]
        key = v.id props
        $ Page, key: key, active: is-active, $ v.component, do
            pkey: key
            mutator: views-mutator
            data: @state.data.views[key]

    render: ->
        [hpages, apages] = split-at @state.data.pages.length - 1, @state.data.pages

        pages = for [view, props] in hpages
            @make-page view, props, false

        apage = null
        title = null
        if apages.length
            [view, props] = apages[0]
            v = views[view]
            title = v.title props
            pages.push @make-page view, props, true

        pages.unshift $ mui.AppBar, title: (title or \Zplayer)
        $div class-name: 'page-container', pages


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


app-data = do
    version: 1
    views:
        mobscreen:
            tabs: {}
    pages: []


app-data-mutator = ->
    console.log 'Data', it
    # console.trace!
    app-data := it
    set-hash!
    localStorage['app-data'] = JSON.stringify app-data
    app.set-state data:it


pages-mutator = ->
    app-data-mutator React.addons.update app-data, pages: $set: it


views-mutator = (key, value) ->
    app-data-mutator React.addons.update app-data, views: (key): $set: value


get-current-pages = ->
    if location.hash
    then location.hash |> (.slice 1) |> decodeURI |> JSON.parse
    else [['mobscreen', null]]


setting-hash = false
window.addEventListener 'hashchange', ->
    if !setting-hash
        pages-mutator get-current-pages!


set-hash = ->
    setting-hash = true
    location.hash = app-data.pages |> JSON.stringify |> encodeURI
    setting-hash = false


stored-data = localStorage['app-data']
if stored-data
    stored-data = JSON.parse stored-data
    if stored-data.version == app-data.version
        app-data = stored-data
        if location.hash
            app-data.pages = get-current-pages!
        else
            set-hash!
else
    app-data.pages = get-current-pages!

app = React.render (App data:app-data), document.get-element-by-id 'app-window'
