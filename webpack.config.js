module.exports = {
    entry: "./src/app.ls",
    output: {
        path: "./www/js/compiled",
        filename: "app.js"
    },
    module: {
        loaders: [
            { test: /\.ls$/, loader: "livescript" }
        ]
    }
};
