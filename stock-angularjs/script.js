const serverURL = window.location.protocol + "\/\/" + window.location.hostname + ":1571\/";
const green_arrow_up = "images/Green_Arrow_Up.png";
const red_arrow_down = "images/Red_Arrow_Down.png";  
        
angular
.module('stockSearch', ['ngMaterial','ngSanitize','ngAnimate'])
.controller('stockController', stockController);

function stockController ($timeout, $q, $log,$rootScope,$scope, $http, $interval) {
var self = this;
self.simulateQuery = false;
self.isDisabled    = false;

self.querySearch   = querySearch;
self.selectedItemChange = selectedItemChange;
self.searchTextChange   = searchTextChange;
self.showWarning = false;
self.quoteButtonEnabled = 'disabled';
//self.quoteButtonEnabled = '';

function querySearch (query) {
if (filterSpace(query)){
    var deferred = $q.defer();

    var queryURL = serverURL + 'autocomplete/' + query;
    $http.get(queryURL).success(
    function(data){
        deferred.resolve(data);
    }
    );

    return deferred.promise;
}
}

function searchTextChange(text) {
self.showWarning = !filterSpace(text);
if (self.showWarning){
    self.quoteButtonEnabled = 'disabled';
}else{
    self.quoteButtonEnabled = '';
}
}

function selectedItemChange(item) {
//$log.info('Item changed to ' + JSON.stringify(item));
self.quoteButtonEnabled = '';
}


self.time_series = [];
self.date_keys = [];
self.parsed_dates = [];
self.currentSymbol = "";
self.today_open = "";
self.today_close = "";
self.yesterday_close = "";
self.change = "";
self.changePercent = "";
self.changeImage = "";
self.changeStr = "";
self.range = "";
self.volume = "";
self.timestamp = "";
self.currentInd = "";
self.currentIndLines = 0;

function getStockAPI(){
    resetButtons();
    self.showDetails = true;
    self.rightNavEnabled = '';
    var apiURL = serverURL + "price\/" + self.searchText;
    getJSON(apiURL,parsePrice);
}

function getIndicatorAPI(ind,lines){
    const apiURL = serverURL + "indicator\/" + self.searchText + "\/" + ind;
    self.currentInd = ind;
    self.currentIndLines = lines;

    getJSON(apiURL,drawIndicatorChart);
}

function getNewsAPI(){
    const apiURL = serverURL + "news\/" + self.currentSymbol;
    getJSON(apiURL,showNews);    
}

function getHistoricalAPI(){
    const apiURL = serverURL + "historical\/" + self.currentSymbol;
    getJSON(apiURL,drawHistoricalChart);
}

function getJSON(url,callback){
    self.showBar = true;
    $http.get(url).success(
        function(data){
            //$log.info(data);
            if (data == "Error"){
                $log.info("Error");   
            }else{
                callback(data);
            }
        }
    );
}

function parsePrice(data){
    self.showBar = false;  
    const meta_data = data["table"];
    self.time_series = data["series"];
    self.date_keys = Object.keys(self.time_series);
    
    self.currentSymbol = meta_data["symbol"]
    self.yesterday_close = meta_data["last_price"];
    self.today_open = meta_data["open"];
    self.today_close = meta_data["close"];
    self.change = meta_data["change"];
    self.changePercent = meta_data["change_percent"]
    if (self.change >= 0){
        self.changeImage = green_arrow_up; 
    }else{
        self.changeImage = red_arrow_down;
    }
    self.changeStr = self.change + "(" + self.changePercent + ")<img height=\"20px\" src=\"" + self.changeImage + "\">";
    self.range = meta_data["range"];
    self.timestamp = meta_data["timestamp"];
    self.volume = meta_data["volume"];

    self.favButtonEnabled = '';
    self.FBButtonEnabled = '';

    drawPriceChart();
}

function drawPriceChart(){
    if (self.time_series.length == 0){
        return;
    }    
    
    const date_keys = self.date_keys;
    const series = self.time_series;
    var prices = [];
    var volumes = [];
    for (var i in date_keys){
       var i_date = date_keys[i];
       var i_item = series[i_date];
       prices.push(parseFloat(i_item["price"]));
       volumes.push(parseFloat(i_item["volume"]));
    }
   
    date_keys.reverse();
    prices.reverse();
    volumes.reverse();

    highChartDrawPrice(self.currentSymbol,date_keys,prices,volumes);
}

function drawIndicatorChart(data){
    self.showBar = false;
    if (self.currentIndLines == 1){
        drawSingleLineChart(data,self.currentSymbol,self.currentInd,self.date_keys);
    }else if(self.currentIndLines == 2){
        drawDoubleLineChart(data,self.currentSymbol,self.currentInd,self.date_keys);                    
    }else if(self.currentIndLines ==3){
        drawTripleLineChart(data,self.currentSymbol,self.currentInd,self.date_keys);                    
    }
}

function drawHistoricalChart(data){
    self.showBar = false; 
    const info = data["info"];
    const symbol = info["symbol"];
    const series = data["series"];
    highChartDrawHistoricalChart(symbol,series);
}

self.newsData = [];

function showNews(data){
    self.showBar = false;
    self.newsData = data;
};

self.favList = [];


function addSymbolToFav(){
for (var i = 0;i < self.favList.length;i++){
    if (self.favList[i]["symbol"] == self.currentSymbol){
        return;
    }
}

self.favButtonStyle = 'glyphicon-star yellow-star'

var symbol = self.currentSymbol;
var price = self.today_close;
var change = self.change;
var changePercent = self.changePercent;
var changeStr = self.changeStr;
var volume = self.volume;
self.favList.push({
        'symbol' : symbol,
        'data' : {
            'price' : price,
            'change' : change,
            'changePercent' : changePercent,
            'changeStr' : changeStr,
            'volume' : volume
        }
    });
};

function removeSymbolFromFav(index){
self.favList.splice(index);
}

function updateFavList(){
for (var i = 0;i < self.favList.length;i++){
    var i_symbol = self.favList[i]["symbol"];
    getPriceFast(i_symbol);
}
}


function getPriceFast(symbol){
    var apiURL = serverURL + "priceFast\/" + symbol;
    getJSON(apiURL,parsePriceFast);
}


function parsePriceFast(data){
self.showBar = false;
var symbol = data["symbol"];
for (var i = 0;i < self.favList.length;i++){
    if (self.favList[i]["symbol"] == symbol){
        var item = self.favList[i]["data"];
        item["price"] = data["price"];
        var change = data["change"];
        var changePercent = data["changePercent"];
        item["change"] = change;
        item["changePercent"] = changePercent;
        var changeImage  = '';
        if (change >= 0){
            changeImage = green_arrow_up; 
        }else{
            changeImage = red_arrow_down;
        }
        var changeStr = change + "(" + changePercent + ")<img height=\"20px\" src=\"" + changeImage + "\">";
        item["changeStr"] = changeStr;

        item["volume"] = numberWithCommas(data["volume"]);
        $log.info(item);
    }
}

}

//Page Manipulation
self.detailsNav = ["active",'',''];
self.detailsDiv = [true,false,false];
self.chartsNav = ["active",'','','','','','','',''];

function activeChartsNav(x){
activeTab(self.chartsNav,x);
}

function activeDetailsNav(x){
    activeTab(self.detailsNav,x);
}

function activeTab(nav,x){
for (var i = 0;i<nav.length;i++){
    if (i == x){
    nav[i] = "active";
    }else{
    nav[i] = "";
    }
}
}

function activeDiv(x){
for (var i=0;i<self.detailsDiv.length;i++){
    if (i == x){
        self.detailsDiv[i] = true;
    }else{
        self.detailsDiv[i] = false;
    }
}
}

self.showBar = true;

//Helpers
function filterSpace(text){
if (text == ''){
    return false;
}

if (text.trim() === ''){
    return false;
}else{
    return true;
}
}


function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}


//HTML interactions
$scope.clearText = function(){
self.selectedItem = null;
self.searchText = '';
self.quoteButtonEnabled = 'disabled';
self.showDetails = false;
}

$scope.getQuote = function(){
    if (self.quoteButtonEnabled != 'disabled'){
        getStockAPI();
    }
}

$scope.drawPrice = function(){
    drawPriceChart();
    activeChartsNav(0);
}

$scope.drawIndicator = function(ind,lines,tab){
    getIndicatorAPI(ind,lines);
    activeChartsNav(tab);
}

$scope.switchCurrentStock = function(){
    activeDetailsNav(0);
    activeDiv(0);
    getStockAPI();  
}

$scope.switchHistoricalChart = function(){
    activeDetailsNav(1); 
    activeDiv(1);
    getHistoricalAPI();
}

$scope.switchNews = function(){
    activeDetailsNav(2); 
    activeDiv(2);
    getNewsAPI();
}

$scope.quoteFav = function(symbol){
    self.currentSymbol = symbol;
    getStockAPI();
}

$scope.addFav = function(){
    if (self.favButtonEnabled != 'disabled'){
    if (self.favButtonStyle == "glyphicon-star-empty"){
        addSymbolToFav();
    }else{
        
        var index = self.favList.indexOf(self.currentSymbol);
        removeSymbolFromFav(index);
        checkFavButton();
    }
    
    }
}

$scope.removeFav = function(index){
removeSymbolFromFav(index);
checkFavButton();
}

$scope.refreshFavList = function(){
    updateFavList();
}


self.autoRefreshFunc = '';
self.enableAutoRefresh = false;
$scope.toggleAutoRefresh = function(){
    
    self.enableAutoRefresh = !self.enableAutoRefresh;
    if (self.enableAutoRefresh){
    $log.info("Start Auto Refresh");
    self.autoRefreshFunc = $interval(updateFavList,5000);
    }else{
    $log.info("Stop Auto Refresh");
    $interval.cancel(self.autoRefreshFunc);
    }
}

self.favButtonEnabled = 'disabled';
self.favButtonStyle = 'glyphicon-star-empty';
self.FBButtonEnabled = 'disabled';

function resetButtons (){ 
self.favButtonEnabled = 'disabled';
self.favButtonStyle = 'glyphicon-star-empty';
self.FBButtonEnabled = 'disabled';
}

function checkFavButton(){
for (var i = 0;i < self.favList.length;i++){
    if (self.favList[i]["symbol"] == self.currentSymbol){
        self.favButtonStyle = 'glyphicon-star yellow-star';
        return;
    }
}
self.favButtonStyle = 'glyphicon-star-empty';
}

self.sortby = 'Default';
self.sortbyDisplay = 'Default';
self.orderby = 'Ascending';

self.orderbyEnabled = 'disabled';
self.defaultOrder = '';

function changeSort(display,sortby){
if (self.favList.length == 0){
    return;
}

if (self.sortby == "Default" && sortby != "Default"){
    self.defaultOrder = self.favList;
}

self.sortbyDisplay = display;
self.sortby = sortby;

if (self.sortbyDisplay == 'Default'){
    self.favList = self.defaultOrder;
    self.orderbyEnabled = 'disabled';    
}else{
    self.orderbyEnabled = '';
    updateSort();
}
}

function updateSort(){
if (self.sortby == "symbol"){
    sortBySymbol();
}else{
    sortByValue();
}
}

function changeOrder(orderby){
if (self.favList.length == 0){
    return;
}
self.orderby = orderby;
updateSort();
}

function sortBySymbol(){
if (self.orderby == "Ascending"){
    self.favList.sort(function(a,b){
        var a_symbol = a["symbol"];
        var b_symbol = b["symbol"];
        if (a_symbol < b_symbol){
            return -1;
        }
        if (a_symbol > b_symbol){
            return 1;
        }        
        return 0;
    });
}else{
    self.favList.sort(function(a,b){
        var a_symbol = a["symbol"];
        var b_symbol = b["symbol"];
        if (a_symbol > b_symbol){
            return -1;
        }
        if (a_symbol < b_symbol){
            return 1;
        }        
        return 0;
    });
}
}

function sortByValue(){
var orderby = self.orderby;

if (self.orderby == "Ascending"){
    self.favList.sort(function(a,b){
        var a_data = parseFloat(a["data"][self.sortby].replace(/,/g, ""));
        var b_data = parseFloat(b["data"][self.sortby].replace(/,/g, ""));
        return a_data - b_data;
    });
}else{
    self.favList.sort(function(a,b){
        var a_data = parseFloat(a["data"][self.sortby].replace(/,/g, ""));
        var b_data = parseFloat(b["data"][self.sortby].replace(/,/g, ""));
        return b_data - a_data;
    });
}
}

$scope.changeSortBy = function(display,sortby){
changeSort(display,sortby);
}

$scope.changeOrderBy = function(orderby){
    changeOrder(orderby);
}

self.rightNavEnabled = 'disabled';

self.showDetails = false;

$scope.gotoList = function(){
self.showDetails = false;
}

$scope.gotoDetails = function(){
    if (self.rightNavEnabled != 'disabled'){
    self.showDetails = true;
    }
}


} 

var currentChart = '';

function highChartExport(){
console.log(currentChart.exportChart());
}

function highChartDrawPrice(symbol, parsed_dates,close_values,volume_values){
currentChart = Highcharts.chart('chart-container', {
    chart :{
    zoomType : 'x'
    },
            title: {
                text: symbol + " Stock Price and Volume"
            },
            subtitle:{
                text : '<a href="https://www.alphavantage.co/" class="blue-anchor" target="_blank">Source: Alpha Advantage</a>',
                useHTML : true
            },
            tooltip: {
                pointFormat : '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>{point.y: .2f}</b><br/>'
            },
            xAxis: {					        	
                categories: parsed_dates,
                tickInterval : 5,
            },
            yAxis: [{ // Primary yAxis
                    labels: {
                        style: {
                            color: Highcharts.getOptions().colors[1]
                        }
                    },
                    title: {
                        text: 'Stock Price',
                        style: {
                            color: Highcharts.getOptions().colors[1]
                        }
                    }
                }, { // Secondary yAxis
                    title: {
                        text: 'Volume',
                        style: {
                            color: Highcharts.getOptions().colors[1]
                        }
                    },
                    labels: {
                        style: {
                            color: Highcharts.getOptions().colors[1]
                        }
                    },
                    opposite: true
                }],
            series: [{
                type : 'area',
                name: symbol,
                data: close_values,
                color : "#393280"
            },{
                yAxis : 1,
                type : 'column',
                name : symbol + "Volume",
                data : volume_values,
                color : "#cf454d"
            }]
        });
}

function drawSingleLineChart(data_json, symbol, acry, parsed_dates){
    var info = data_json['info'];
    var data_series = data_json['series'];

    var symbol = info['symbol'];
    var ind_title = info['ind_title'];
    var ind_acry = info['ind_acry'];
    var date_keys = Object.keys(data_series);
    var ind_keys =  Object.keys(data_series[date_keys[0]]);

    var x_data = [];

    for (var i = 0;i<date_keys.length;i++){
        x_data.push( parseFloat((data_series[date_keys[i]])[ind_keys[0]]) );
    }

    date_keys.reverse();
    x_data.reverse();

    var y_ticks = yIntervalHelper(x_data);
    
    currentChart = Highcharts.chart('chart-container', {
        chart :{
            zoomType : 'x'
        },
        title: {
            text: '<span style=\"font-size:14px\">' + ind_title + '</span>',
        },
        subtitle:{
            text : '<a href="https://www.alphavantage.co/" class="blue-anchor" target="_blank">Source: Alpha Advantage</a>',
            useHTML : true
        },
        xAxis: {                                
            categories: date_keys,
            tickInterval : 5,
            minorGridLineWidth: 0,
            minorTickInterval: 'auto',
            minorTickColor: '#d7606a',
            minorTickWidth: 1,
            endOnTick : true
        },
        yAxis: { // Primary yAxis
                floor: y_ticks[0],
                ceiling: y_ticks[1],
                labels: {
                    style: {
                        color: Highcharts.getOptions().colors[1]
                    }
                },
                title: {
                    text: ind_acry,
                    style: {
                        color: Highcharts.getOptions().colors[1]
                    }
                }
            },
        legend: {
            align : 'center',
            verticalAlign :'bottom'
        },
        series: [{
            type : 'line',
            name: symbol,
            data: x_data,
            color : '#d7606a',
            lineWidth : 1,
            marker: {
                enabled: true,
                radius: 1
            }                               
            }
        ]
    });                    
    }

function drawDoubleLineChart(data_json, symbol, acry, parsed_dates){
    var info = data_json['info'];
    var data_series = data_json['series'];

    var symbol = info['symbol'];
    var ind_title = info['ind_title'];
    var ind_acry = info['ind_acry'];
    var date_keys = Object.keys(data_series);
    var ind_keys =  Object.keys(data_series[date_keys[0]]);

    var x_data_0 = [];
    var x_data_1 = [];

    for (var i = 0;i<date_keys.length;i++){
        x_data_0.push(parseFloat((data_series[date_keys[i]])[ind_keys[0]]));
        x_data_1.push(parseFloat((data_series[date_keys[i]])[ind_keys[1]]));   
    }

    date_keys.reverse();
    x_data_0.reverse();
    x_data_1.reverse();

    var y_ticks = yIntervalHelper(x_data_0);
    
    currentChart = Highcharts.chart('chart-container', {
        chart :{
            zoomType : 'x'
        },
        title: {
            text: '<span style=\"font-size:14px\">' + ind_title + '</span>',
        },
        subtitle:{
            text : '<a href="https://www.alphavantage.co/" class="blue-anchor" target="_blank">Source: Alpha Advantage</a>',
            useHTML : true
        },
        xAxis: {                                
            categories: date_keys,
            tickInterval : 5,
            minorGridLineWidth: 0,
            minorTickInterval: 'auto',
            minorTickColor: '#d7606a',
            minorTickWidth: 1,
            endOnTick : true
        },
        yAxis: { // Primary yAxis
                floor: y_ticks[0],
                ceiling: y_ticks[1],
                labels: {
                    style: {
                        color: Highcharts.getOptions().colors[1]
                    }
                },
                title: {
                    text: ind_acry,
                    style: {
                        color: Highcharts.getOptions().colors[1]
                    }
                }
            },
        legend: {
            align : 'center',
            verticalAlign :'bottom'
        },
        series: [{
                    type : 'line',
                    name: symbol + " " + ind_keys[0],
                    data: x_data_0,
                    color : '#d7606a',
                    lineWidth : 1,
                    marker: {
                        enabled: true,
                        radius: 1
                    }                               
                    },
                    {
                    type : 'line',
                    name: symbol + " " + ind_keys[1],
                    data: x_data_1,
                    color : '#00bfff',
                    lineWidth : 1,
                    marker: {
                        enabled: true,
                        radius: 1
                    }                               
                    }
        ]
    });
    }

function drawTripleLineChart(data_json, symbol, acry, parsed_dates){
    var info = data_json['info'];
    var data_series = data_json['series'];

    var symbol = info['symbol'];
    var ind_title = info['ind_title'];
    var ind_acry = info['ind_acry'];
    var date_keys = Object.keys(data_series);
    var ind_keys =  Object.keys(data_series[date_keys[0]]);

    var x_data_0 = [];
    var x_data_1 = [];
    var x_data_2 = [];

    for (var i = 0;i<date_keys.length;i++){
        x_data_0.push(parseFloat((data_series[date_keys[i]])[ind_keys[0]]));
        x_data_1.push(parseFloat((data_series[date_keys[i]])[ind_keys[1]]));
        x_data_2.push(parseFloat((data_series[date_keys[i]])[ind_keys[2]]));     
    }

    date_keys.reverse();
    x_data_0.reverse();
    x_data_1.reverse();
    x_data_2.reverse();

    var y_ticks = yIntervalHelper(x_data_0);
    
    currentChart = Highcharts.chart('chart-container', {
        chart :{
            zoomType : 'x'
        },
        title: {
            text: '<span style=\"font-size:14px\">' + ind_title + '</span>',
        },
        subtitle:{
            text : '<a href="https://www.alphavantage.co/" class="blue-anchor" target="_blank">Source: Alpha Advantage</a>',
            useHTML : true
        },
        xAxis: {                                
            categories: date_keys,
            tickInterval : 5,
            minorGridLineWidth: 0,
            minorTickInterval: 'auto',
            minorTickColor: '#d7606a',
            minorTickWidth: 1,
            endOnTick : true
        },
        yAxis: { // Primary yAxis
                floor: y_ticks[0],
                ceiling: y_ticks[1],
                labels: {
                    style: {
                        color: Highcharts.getOptions().colors[1]
                    }
                },
                title: {
                    text: ind_acry,
                    style: {
                        color: Highcharts.getOptions().colors[1]
                    }
                }
            },
        legend: {
            align : 'center',
            verticalAlign :'bottom'
        },
        series: [{
                    type : 'line',
                    name: symbol + " " + ind_keys[0],
                    data: x_data_0,
                    color : '#d7606a',
                    lineWidth : 1,
                    marker: {
                        enabled: true,
                        radius: 1
                    }                               
                    },
                    {
                    type : 'line',
                    name: symbol + " " + ind_keys[1],
                    data: x_data_1,
                    color : '#00bfff',
                    lineWidth : 1,
                    marker: {
                        enabled: true,
                        radius: 1
                    }                               
                    },
                    {
                    type : 'line',
                    name: symbol + " " + ind_keys[2],
                    data: x_data_2,
                    color : '#00b200',
                    lineWidth : 1,
                    marker: {
                        enabled: true,
                        radius: 1
                    }                               
                    }
                ]
    });
                                
}

function yIntervalHelper(arr){   
        var max = arr[0];
        var min = arr[1];
        for (var i=0;i<arr.length;i++){
            if ( arr[i] > max ){
                max = arr[i];
            }
            if (arr[i] < min){
                min = arr[i];
            }
        }

        var result = [];
        result.push(min);
        result.push(max);

        return result;
    }



function highChartDrawHistoricalChart(symbol,data){
    var chart = Highcharts.stockChart('historical-chart-container', {
                
        title: {
            text: symbol + " Stock Value"
        },

        subtitle: {
            text : '<a href="https://www.alphavantage.co/" class="blue-anchor" target="_blank">Source: Alpha Advantage</a>',
            useHTML : true
        },

        rangeSelector: {
            allButtonsEnabled: true,
            buttons: [{
                type: 'month',
                count: 1,
                text: '1m',       
            }, {
                type : 'month',
                count: 3,
                text : '3m'
            },{
                type: 'month',
                count: 6,
                text: '6m'
            },{
                type: 'year',
                count: 1,
                text: '1y'
            },{
                type: 'all',
                text: 'ALL'
            }

        ],
            
            selected: 0
        },

        series: [{
            name: symbol + 'Stock Price',
            data: data,
            type: 'area',
            threshold: 0,
            tooltip: {
                valueDecimals: 2
            }
        }],

        responsive: {
            rules: [{
                condition: {
                    maxWidth: 500
                },
                chartOptions: {
                    chart: {
                        height: 300
                    },
                    subtitle: {
                        text: null
                    },
                    navigator: {
                        enabled: false
                    }
                }
            }]
        }
    });
}
