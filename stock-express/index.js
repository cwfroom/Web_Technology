var express = require('express')
var http = require('http');
var https = require('https');
var app = express()

var autoCompleteURL = 'http://dev.markitondemand.com/MODApis/Api/v2/Lookup/json?input=';


app.get('/', function (req, res) {
  res.sendFile('stock.html', {root:__dirname});
})


app.get('/autocomplete/:symbol',autoComplete);
app.get('/price/:symbol',getPrice);
app.get('/indicator/:symbol/:ind',getIndicator)

app.listen(8000, function () {
  console.log('Listening on port 8000!')
})

function autoComplete(req,res){
	var symbol = req.params.symbol;
	fetchJSON(http,res,autoCompleteURL+symbol, autoCompleteParse);
}

function getPriceFast(req,res){

}

function getPrice(req,res){
	var symbol = req.params.symbol;
	var alpha_base_url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=";
	var alpha_api_key = "QUEJMT41CEQTOAWN";
	var alpha_url =  alpha_base_url + symbol + "&outputsize=full&apikey=" + alpha_api_key;
	console.log(alpha_url);

	//res.sendFile('AAPL.json', {root:__dirname});
	fetchJSON(https,res,alpha_url,echoJSON);

}

function getIndicator(req,res){
	var symbol = req.params.symbol;
	var ind = req.params.ind;
	var ind_url = "https://www.alphavantage.co/query?function=" + ind + "&symbol=" + symbol + "&interval=daily&time_period=10&series_type=close&apikey=QUEJMT41CEQTOAWN";
	
	fetchJSON(https,res,ind_url,echoJSON);
	//res.sendFile('SMA.json', {root:__dirname});
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

function priceParse(res,json){

}

function echoJSON(res, data){
	res.send(data);
}

