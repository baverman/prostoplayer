var express = require('express');  
var request = require('request');

var app = express();  

app.use('/www', express.static('www'));

app.use('/api', function(req, res) {  
  var url = 'http://zvooq.ru/api' + req.url;
  req.pipe(request(url)).pipe(res);
});

app.listen(process.env.PORT || 3000);  
