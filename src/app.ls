React = require 'react/addons'
window.$ = React.create-element
window.$$ = React.create-factory
for key, value of React.DOM
    window."$#key" = value

(require 'react-tap-event-plugin')!

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()

{Mobscreen} = require './mobscreen.ls'
require './app.styl'

window._CORS = true


App = $$ React.create-class do
    child-context-types:
        mui-theme: React.PropTypes.object

    render: ->
        $ Mobscreen, tab: 1

    get-child-context: ->
        mui-theme: ThemeManager.get-current-theme!

React.render App!, document.get-element-by-id 'app-window'
