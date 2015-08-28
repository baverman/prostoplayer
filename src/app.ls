React = require 'react/addons'
window.$ = React.create-element
window.$$ = React.create-factory
for key, value of React.DOM
    window."$#key" = value

(require 'react-tap-event-plugin')!

{split-at} = require 'prelude-ls'
mui = require 'material-ui'
route = (require 'rlite-router')!
ThemeManager = new mui.Styles.ThemeManager()

require './app.styl'
{Mobscreen} = require './mobscreen.ls'

window._CORS = true


Page = React.create-class do
    render: ->
        top-page = if @props.active then 'top-page' else 'page'
        $div class-name: top-page, @props.children


App = $$ React.create-class do
    child-context-types:
        mui-theme: React.PropTypes.object

    get-child-context: ->
        mui-theme: ThemeManager.get-current-theme!

    get-initial-state: ->
        pages: []

    add: ->
        @state.pages.push(it)
        @set-state pages: @state.pages

    render: ->
        [hpages, apages] = split-at @state.pages.length - 1, @state.pages

        pages = for p in hpages
            $ Page, active: false, p!

        if apages.length
            pages.push $ Page, active: true, apages[0]!

        $div class-name: 'page-container', pages


app = React.render App!, document.get-element-by-id 'app-window'


route.add '', ->
    app.add -> $ Mobscreen, tab: 1


route.add 'release/:id', ->
    app.add -> $div null, 'Release #{it.params.id}'


route.add 'playlist/:id', ->
    app.add -> $div null, 'Playlist #{it.params.id}'


process-hash = ->
    hash = location.hash or '#'
    route.run hash.slice 1


window.addEventListener 'hashchange', process-hash
process-hash!
