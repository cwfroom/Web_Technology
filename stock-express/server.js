var express = require('express')
var http = require('http');
var https = require('https');
var fs = require('fs');
var path = require('path');
var parseString = require('xml2js').parseString;
var moment = require('moment-timezone');
var app = express()


var autoCompleteURL = 'http://dev.markitondemand.com/MODApis/Api/v2/Lookup/json?input=';


app.use(function(res,res,next){
	res.header("Access-Control-Allow-Origin","*");
	res.header("Access-Control-Allow-Headers","Origin, X-Requested-With, Content-Type, Accept");
	next();

});

app.get('/', function (req, res) {
  res.sendFile('stock.html', {root:__dirname});
})

app.get('/file/:filename',function (req,res){
	
})


app.get('/autocomplete/:symbol',autoComplete);
app.get('/price/:symbol',getPrice);
app.get('/priceraw/:symbol',getPriceRaw);
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
	if (debug){
		console.log(symbol);
	}
	fetchData(http,res,autoCompleteURL+symbol, autoCompleteParse);
}

function getPriceRaw(req,res){
	var symbol = req.params.symbol;
	var alpha_base_url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=";
	var alpha_api_key = "QUEJMT41CEQTOAWN";
	var alpha_url =  alpha_base_url + symbol + "&outputsize=full&apikey=" + alpha_api_key;
	console.log(alpha_url);

	if (debug){
		readFile(res, '/debug/' + symbol + '.json',echoJSON);
	}else{
		fetchData(https,res,alpha_url,echoJSON);
	}
}

function getPriceFast(req,res){
	var symbol = req.params.symbol;
	var alpha_base_url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=";
	var alpha_api_key = "QUEJMT41CEQTOAWN";
	var alpha_url =  alpha_base_url + symbol + "&apikey=" + alpha_api_key;
	console.log(alpha_url);

	if (debug){
		console.log(Date.now());
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
		readFile(res, '/debug/SMA.json',parseIndicator);
	}else{
		fetchData(https,res,ind_url,parseIndicator);
	}
	
	
}

function getNews(req,res){
	var symbol = req.params.symbol;
	var news_url = "https://seekingalpha.com/api/sa/combined/" + symbol + ".xml";
	if (debug){
		console.log(news_url);
		readFile(res,'/debug/AAPL.xml',parseNews);
	}else{
		fetchData(https,res,news_url,parseNews);
	}
	
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
	res.send('Error');
}

function parsePrice(res,data){
	try{
		data = JSON.parse(data);
	}catch (e){
		replyError(res);
		return;
	}

	var result = {};
	var series = {};

	var meta_data = data["Meta Data"];
	var time_series = data["Time Series (Daily)"];
	var date_keys = Object.keys(time_series);
	var today_data = time_series[date_keys[0]];
	var yesterday_data = time_series[date_keys[1]];

	var currentSymbol = meta_data["2. Symbol"];
	var today_open = parseFloat(today_data["1. open"]).toFixed(2);
	var today_close = parseFloat(today_data["4. close"]).toFixed(2);
	var yesterday_close = parseFloat(yesterday_data["4. close"]).toFixed(2);
   
	var change = (today_close - yesterday_close).toFixed(2);
	var changePercent = (change / yesterday_close * 100).toFixed(2) + "%";
	
	var range = parseFloat(today_data["3. low"]).toFixed(2) + "-" + parseFloat(today_data["2. high"]).toFixed(2);
	var timestamp = moment(meta_data["3. Last Refreshed"]).tz('America/New_York').format('YYYY-MM-DD HH:mm:ss z'); 
	var volume = today_data["5. volume"];
	
	result['table'] = {
		'symbol' : currentSymbol,
		'last_price' : today_close,
		'change' : change,
		'change_percent' : changePercent,
		'timestamp' : timestamp,
		'open' : today_open,
		'close' : yesterday_close,
		'range' : range,
		'volume' : volume
		
	};

	var today_date = date_keys[0];
	var today_date_split = today_date.split("-");
	var current_month = today_date_split[1];
	var current_day = today_date_split[2];

	for (var i in date_keys){
	  var i_date = date_keys[i];
	  var i_date_split = i_date.split("-");
	  var i_month = i_date_split[1];
	  var i_day = i_date_split[2];

	  var i_item = time_series[i_date];

	  var i_parsed_date = i_month + "/" + i_day;
	  var i_close = parseFloat(i_item["4. close"]).toFixed(2);
	  var i_volume = parseFloat(i_item["5. volume"]).toFixed(2);

	  series[i_parsed_date] = {
	  	'price' : i_close,
		'volume' : i_volume
	  }


	  if (i_month == current_month-6 && i_day <= current_day && (i % 5) ==0){
		break;
	  }
	}

	result['series'] = series;
	
	res.send(result);

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

function parseIndicator(res, json){
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

	var result = {};
	var series = {};

	var root_keys = Object.keys(json);
    var symbol = (json[root_keys[0]])["1: Symbol"]
    var ind_title = (json[root_keys[0]])["2: Indicator"];
    var data_series = json[root_keys[1]];
    var date_keys = Object.keys(data_series);
    var ind_keys =  Object.keys((json[root_keys[1]])[date_keys[0]]);
    var ind_acry = (root_keys[1].split(" "))[2];

    result['info'] = {
    	'symbol' : symbol,
    	'ind_title' : ind_title,
    	'ind_acry' : ind_acry
    }

	var today_date = date_keys[0];
	var today_date_split = today_date.split("-");
	var current_month = today_date_split[1];
	var current_day = today_date_split[2];

	for (var i in date_keys){
	  var i_date = date_keys[i];
	  var i_date_split = i_date.split("-");
	  var i_month = i_date_split[1];
	  var i_day = i_date_split[2];

	  var i_item = data_series[i_date];

	  var i_parsed_date = i_month + "/" + i_day;

	  series[i_parsed_date] = i_item;

	  if (i_month == current_month-6 && i_day <= current_day && (i % 5) ==0){
		break;
	  }
	}

	result['series'] = series;

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


