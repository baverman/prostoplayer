'use strict';
var webpack = require('webpack')

var hotReload = process.env['HOT_RELOAD']

var entries = ['./src/app.ls']
var jsLoaders = ['livescript']

if (hotReload) {
    jsLoaders.unshift('react-hot')
    entries.unshift('webpack-dev-server/client?http://0.0.0.0:3001',
                    'webpack/hot/only-dev-server')
}

module.exports = {
    entry: entries,
    output: {
        path: './www/js/compiled',
        filename: 'app.js',
        publicPath: '/www/js/compiled',
    },
    module: {
        loaders: [
            { test: /\.ls$/, loaders: jsLoaders },
            { test: /\.styl$/, loader: 'style-loader!css-loader!stylus-loader' }
        ]
    },
    plugins: [
        new webpack.NoErrorsPlugin()
    ],
    devServer: {
        proxy: {
            '*': 'http://localhost:3000'
        },
        historyApiFallback: true
    }
};
