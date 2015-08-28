module.exports = {
    entry: './src/app.ls',
    output: {
        path: './www/js/compiled',
        filename: 'app.js'
    },
    module: {
        loaders: [
            { test: /\.ls$/, loader: 'livescript' },
            { test: /\.styl$/, loader: 'style-loader!css-loader!stylus-loader' }
        ]
    }
};
