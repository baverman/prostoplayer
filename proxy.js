var express = require('express');  
var request = require('request');

var app = express();  

app.use('/www', express.static('www'));

app.use('/', function(req, res) {  
  var url = 'http://zvooq.ru' + req.url;
  req.pipe(request(url)).pipe(res);
});

app.listen(process.env.PORT || 3000);  
