var express = require('express')
var http = require('http');
var https = require('https');
var fs = require('fs');
var path = require('path');
var parseString = require('xml2js').parseString;
var moment = require('moment-timezone');
var app = express()


var autoCompleteURL = 'http://dev.markitondemand.com/MODApis/Api/v2/Lookup/json?input=';


app.get('/', function (req, res) {
  res.sendFile('stock.html', {root:__dirname});
})

app.get('/file/:filename',function (req,res){
	
})


app.get('/autocomplete/:symbol',autoComplete);
app.get('/price/:symbol',getPrice);
app.get('/pricefast/:symbol',getPriceFast);
app.get('/indicator/:symbol/:ind',getIndicator);
app.get('/news/:symbol',getNews);

var debug = process.argv.slice(2);
if (debug == 'debug'){
	debug = true;
}else{
	debug = false
}

var port = 0;

if (debug){
	console.log('Running debug mode');
	port = 8000;
}else{
	console.log('Running production mode');
	port = process.env.PORT || 3000
}

app.listen(port, function () {
  console.log('Listening on ' + port);
})


function autoComplete(req,res){
	var symbol = req.params.symbol;
	fetchData(http,res,autoCompleteURL+symbol, autoCompleteParse);
}

function getPriceFast(req,res){
	var symbol = req.params.symbol;
	var alpha_base_url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=";
	var alpha_api_key = "QUEJMT41CEQTOAWN";
	var alpha_url =  alpha_base_url + symbol + "&apikey=" + alpha_api_key;
	console.log(alpha_url);

	if (debug){
		readFile(res,'/debug/' + symbol + "fast.json",echoJSON);
	}else{
		fetchData(https,res,alpha_url,parsePriceFast);
	}
}

function getPrice(req,res){
	var symbol = req.params.symbol;
	var alpha_base_url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=";
	var alpha_api_key = "QUEJMT41CEQTOAWN";
	var alpha_url =  alpha_base_url + symbol + "&outputsize=full&apikey=" + alpha_api_key;
	console.log(alpha_url);

	if (debug){
		readFile(res, '/debug/' + symbol + '.json',parsePrice);
	}else{
		fetchData(https,res,alpha_url,parsePrice);
	}
}

function getIndicator(req,res){
	var symbol = req.params.symbol;
	var ind = req.params.ind;
	var ind_url = "https://www.alphavantage.co/query?function=" + ind + "&symbol=" + symbol + "&interval=daily&time_period=10&series_type=close&apikey=QUEJMT41CEQTOAWN";
	
	if (debug){
		readFile(res, '/debug/SMA.json',echoJSON);
	}else{
		fetchData(https,res,ind_url,echoJSON);
	}
	
	
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

function readFile(res,filename,callback){
	fs.readFile(path.join(__dirname,filename), 'utf8', function(err,data){
		callback(res,data);
	})
}

function autoCompleteParse(res, json){
	try{
		json = JSON.parse(json);
	}catch (e){
		replyError(res);
		return;
	}
	var result = [];
	for (var i in json){
		var item = {'value' : json[i].Symbol, 'display' : json[i].Symbol + ' - ' + json[i].Name + ' (' + json[i].Exchange +')'};
		result.push(item);
	}
	res.send(result);
}

function replyError(res){
	res.send("Error");
}

function parsePrice(res,json){
	try{
		json = JSON.parse(json);
	}catch (e){
		replyError(res);
		return;
	}

	res.send(json);

}

function parsePriceFast(res,json){
	try{
		json = JSON.parse(json);
	}catch (e){
		replyError(res);
		return;
	}
	
	
	var meta_data = json["Meta Data"];
	if (meta_data === undefined){
		replyError(res);
		return;
	}

	var current_symbol = meta_data["2. Symbol"];

	var time_series = json["Time Series (Daily)"];
	var date_keys = Object.keys(time_series);
	var today_data = time_series[date_keys[0]];
	var yesterday_data = time_series[date_keys[1]];

	today_close = parseFloat(today_data["4. close"]).toFixed(2);
	yesterday_close = parseFloat(yesterday_data["4. close"]).toFixed(2);
	change = (today_close - yesterday_close).toFixed(2);
	changePercent = (change / yesterday_close * 100).toFixed(2) + "%";
	volume = today_data["5. volume"];
	
	var result = {
		"symbol" : current_symbol,
		"price" : today_close,
		"change" : change,
		"changePercent" : changePercent,
		"volume" : volume
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


