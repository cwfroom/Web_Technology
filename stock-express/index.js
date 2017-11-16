var express = require('express')
var http = require('http');
var https = require('https');
var parseString = require('xml2js').parseString;
var moment = require('moment-timezone');
var app = express()


var autoCompleteURL = 'http://dev.markitondemand.com/MODApis/Api/v2/Lookup/json?input=';


app.get('/', function (req, res) {
  res.sendFile('stock.html', {root:__dirname});
})


app.get('/autocomplete/:symbol',autoComplete);
app.get('/price/:symbol',getPrice);
app.get('/indicator/:symbol/:ind',getIndicator);
app.get('/news/:symbol',getNews);

app.listen(8000, function () {
  console.log('Listening on port 8000!')
})

function autoComplete(req,res){
	var symbol = req.params.symbol;
	fetchData(http,res,autoCompleteURL+symbol, autoCompleteParse);
}

function getPriceFast(req,res){

}

function getPrice(req,res){
	var symbol = req.params.symbol;
	var alpha_base_url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=";
	var alpha_api_key = "QUEJMT41CEQTOAWN";
	var alpha_url =  alpha_base_url + symbol + "&outputsize=full&apikey=" + alpha_api_key;
	console.log(alpha_url);

	res.sendFile('AAPL.json', {root:__dirname});
	//fetchJSON(https,res,alpha_url,echoJSON);
}

function getIndicator(req,res){
	var symbol = req.params.symbol;
	var ind = req.params.ind;
	var ind_url = "https://www.alphavantage.co/query?function=" + ind + "&symbol=" + symbol + "&interval=daily&time_period=10&series_type=close&apikey=QUEJMT41CEQTOAWN";
	
	fetchData(https,res,ind_url,echoJSON);
	//res.sendFile('SMA.json', {root:__dirname});
}

function getNews(req,res){
	var symbol = req.params.symbol;
	var news_url = "https://seekingalpha.com/api/sa/combined/" + symbol + ".xml";
	fetchData(https,res,news_url,parseNews);

}



function fetchData(protocal, res, url,callback){
	protocal.get(url, (resp) =>{
		let data = '';
		resp.on('data', (chunk) => {
			data += chunk;
		});

		resp.on('end',() => {
			callback(res, data);
		})
	})
}

function autoCompleteParse(res, json){
	json = JSON.parse(json);
	var result = [];
	for (var i in json){
		var item = {'value' : json[i].Symbol, 'display' : json[i].Symbol + ' - ' + json[i].Name + ' (' + json[i].Exchange +')'};
		result.push(item);
	}
	res.send(result);
}

function parseNews(res,xml){
	
	parseString(xml, function (err, result){
		
		var items = result["rss"]["channel"][0]["item"];
		
		var parsedIndex = 0;
		var itemIndex = 0;
		var parsed = [];

		while (parsedIndex < 5){		
			var item = items[itemIndex];
			var link = item["link"][0];
			var parsedDate = moment.tz(item["pubDate"][0],"America/New_York").format('ddd, DD MMM YYYY HH:mm:ss z');
			if (link.includes("article")){
				var parsedItem = {
					"title" : item["title"][0],
					"link" : item["link"][0],
					"author" : item["sa:author_name"][0],
					"date" : parsedDate
				}
				parsed.push(parsedItem);
				parsedIndex++;	
			}
		
			itemIndex++;			
		}
		res.send(parsed);
	});
	
}

function echoJSON(res, data){
	data = JSON.parse(data);
	res.send(data);
}

