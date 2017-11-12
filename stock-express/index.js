var express = require('express')
var http = require('http');
var https = require('https');
var app = express()

var autoCompleteURL = 'http://dev.markitondemand.com/MODApis/Api/v2/Lookup/json?input=';


app.get('/', function (req, res) {
  res.sendFile('stock.html', {root:__dirname});
})


app.get('/autocomplete/:symbol',autoComplete);

app.listen(8000, function () {
  console.log('Listening on port 8000!')
})

function autoComplete(req,res){
	var symbol = req.params.symbol;
	fetchJSON(http,res,autoCompleteURL+symbol, autoCompleteParse);
}

function fetchJSON(protocal, res, jsonURL,callback){
	protocal.get(jsonURL, (resp) =>{
		let data = '';
		resp.on('data', (chunk) => {
			data += chunk;
		});

		resp.on('end',() => {
			var parsed = JSON.parse(data);
			console.log(parsed);
			callback(res, parsed);
		})
	})
}

function autoCompleteParse(res, json){
	var result = [];
	for (var i in json){
		var item = {'value' : json[i].Symbol, 'display' : json[i].Symbol + ' - ' + json[i].Name + ' (' + json[i].Exchange +')'};
		result.push(item);
	}
	res.send(result);
}

function echoJSON(res, data){
	res.send(data);
}

