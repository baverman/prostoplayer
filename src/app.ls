React = require 'react/addons'
window.$ = React.create-element
for key, value of React.DOM
    window."$#key" = value

{Mobscreen} = require './mobscreen.ls'

window._CORS = true


App = React.create-class do
    render: ->
        $ Mobscreen, tab: 1

React.render ($ App), (document.get-element-by-id 'app')
