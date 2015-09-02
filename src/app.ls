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
    child-context-types:
        mui-theme: React.PropTypes.object
        app: React.PropTypes.object

    get-child-context: ->
        self = @
        do
            mui-theme: ThemeManager.get-current-theme!
            app: self

    get-initial-state: ->
        views: @props.views

    add: ->
        @state.views.push(it)
        window.location.hash = @state.views |> JSON.stringify |> encodeURI
        @set-state views: @state.views

    render: ->
        [hpages, apages] = split-at @state.views.length - 1, @state.views

        pages = for p in hpages
            $ Page, active: false, views[p.view] p.props

        apage = null
        title = null
        if apages.length
            apage = views[apages[0].view] apages[0].props
            title = apages[0].title
            pages.push $ Page, active: true, apage

        pages.unshift $ mui.AppBar, title: (title or \Zplayer)
        $div class-name: 'page-container', pages


views = do
    mobscreen: (props) -> $ Mobscreen, props
    release: (props) -> $ Release, props


process-hash = ->
    views = if location.hash
            then location.hash |> (.slice 1) |> decodeURI |> JSON.parse
            else [{view: 'mobscreen', props: tab: 1}]
    React.render (App views:views), document.get-element-by-id 'app-window'

process-hash!

# window.addEventListener 'hashchange', process-hash
