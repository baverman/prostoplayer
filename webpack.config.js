'use strict';
var webpack = require('webpack')

module.exports = {
    entry: [
        'webpack-dev-server/client?http://0.0.0.0:3001',
        'webpack/hot/only-dev-server',
        './src/app.ls'
    ],
    output: {
        path: './www/js/compiled',
        filename: 'app.js',
        publicPath: '/www/js/compiled',
    },
    module: {
        loaders: [
            { test: /\.ls$/, loaders: ['react-hot', 'livescript'] },
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
