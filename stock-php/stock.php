<html>
	<head>
		<title>Stock Search</title>
		<style>
			tr{
				height: 25px;
			}
			#title{
				text-align: center;
				font-style: italic;
				font-size: 24px;
			}
			.searchtable{
				margin: auto;
				background-color: #f5f5f5;
				border-color: #e3e3e3;
			}
			div.divider{
				height: 10px;
			}
			.resultTable{
				font-family: Arial, "Helvetica Neue", Helvetica, sans-serif;
				border-collapse: collapse;
				margin: auto;
				width: 960px;
			}
			.resultTable td{
				border-style: solid;
				border-width: 1px;
				border-color: #e3e3e3;
			}
			.resultTable .leftCol{
				text-align: left;
				background-color: #f3f3f3;
				width: 30%;
				font-weight: bold;
				color: #494146;
			}
			.resultTable .rightCol{
				text-align: center;
				background-color: #fbfbfb;
				width: 70%;
			}
			.resultTable .newsRow{
				text-align: left;
				background-color: #fbfbfb;
				font-size: 16px; 
			}
			.resultTable .newsRow a{
				text-decoration: none;
			}
			.arrow{
				height: 20px;
			}
			.indicator{
				margin-right: 15px;
			}
			.showHideNews{
				width: 960px;
				margin: auto;
				text-align: center;	
				
			}
			.showHideNews ul{
				list-style-type: none;
			}
			.showHideNews a{
				text-decoration: none;
				color: #bebebe;
			}
			.showHideNews img{
				height: 25px;
			}
			#chart-container{
				border-style: solid;
				border-color: #e3e3e3;
				border-width: 1px;	
				width: 960px;
				height: 450px;
				margin: auto;
			}
			.bule-anchor{
				color: #0000ff;
				text-decoration: none;
			}
			.highcharts-anchor{
				fill: #0000ff;
			}
			.highcharts-anchor:hover{
				fill: #666666;
			}

		</style>
		<script src="https://code.highcharts.com/highcharts.js"></script>
		<script src="https://code.highcharts.com/modules/exporting.js"></script>
		<script type="text/javascript">
			function searchClick(){
				if (document.getElementById('queryText').value != ""){
					document.queryForm.submit();
				}else{
					window.alert("Please enter a symbol");
				}

			}

			function clearClick(){
				document.getElementById('queryText').value = "";
				document.queryForm.submit();
			}

			function loadJSON(url, drawfunc, acry) {
				var xmlhttp;
				if (window.XMLHttpRequest) {
					// code for IE7+, Firefox, Chrome, Opera, Safari
					xmlhttp=new XMLHttpRequest();
				}else {
					// code for IE6, IE5
					xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
				}

				xmlhttp.open("GET",url,true); //synchronous request
				xmlhttp.onload = function (e){
					if (xmlhttp.readyState === 4){
						var parsed_json = JSON.parse(xmlhttp.responseText);
						drawfunc(parsed_json, acry);
					}
				} 

				xmlhttp.send();

			}

			function constructJSONurl(ind){
				var ind_url = "https://www.alphavantage.co/query?function=" + ind + "&symbol=" + document.getElementById("queryText").value + "&interval=daily&time_period=10&series_type=close&apikey=QUEJMT41CEQTOAWN";
				//console.log("Loading " + ind_url);
				return ind_url;
			}

			function loadSMAChart(){
				var sma_url = constructJSONurl("SMA");
				loadJSON(sma_url,drawSingleLineChart, "SMA");
				//loadJSON("SMA.json",drawSingleLineChart);
			}

			function loadEMAChart(){
				var ema_url = constructJSONurl("EMA");
				loadJSON(ema_url,drawSingleLineChart, "EMA")
			}

			function loadSTOCHChart(){
				var stoch_url = constructJSONurl("STOCH");
				loadJSON(stoch_url,drawDoubleLineChart, "STOCH");
			}

			function loadRSIChart(){
				var rsi_url = constructJSONurl("RSI");
				loadJSON(rsi_url, drawSingleLineChart, "RSI");
			}

			function loadADXChart(){
				var adx_url = constructJSONurl("ADX");
				loadJSON(adx_url, drawSingleLineChart, "ADX");
			}

			function loadCCIChart(){
				var cci_chart = constructJSONurl("CCI");
				loadJSON(cci_chart,drawSingleLineChart, "CCI");
			}

			function loadBBANDSChart(){
				var bbans_chart = constructJSONurl("BBANDS");
				loadJSON(bbans_chart,drawTripleLineChart, "BBANDS");
				//loadJSON("BBANDS.json",drawTripleLineChart);
			}

			function loadMACDChart(){
				var macd_chart = constructJSONurl("MACD");
				loadJSON(macd_chart,drawTripleLineChart, "MACD");
			}

	</script>



	</head>
	<body onload="drawPriceChart()">
		<?php
			$query = "";
			if (isset($_GET['q'])){
				$query = $_GET['q'];
			}			
		?>


		<table frame="box" class="searchtable">
			<tr>
				<td colspan=2 id="title">Stock Search</td>
			</tr>
			<tr>
				<td colspan=2><hr style="border-top 1px; border-bottom: 0; border-color:#e3e3e3; background-color: #e3e3e3"></td>
			</tr>
			<tr>
				<td>Enter Stock Ticker Symbol*</td>
				<td>
					<form name="queryForm" action=''>
					<input id="queryText" type="text" name="q" maxlength="255" size="50" value="<?php echo $query?>" autocomplete="off">
					<form>
				</td>
			</tr>
			<tr>
				<td></td>
				<td>
					<input type="button" name="search" value="Search" onclick=searchClick()>
					<input type="button" name="clear" value="Clear" onclick=clearClick()>
				</td>
			</tr>
			<tr>
				<td>* - Mandatory fields.</td>
			</tr>
		</table>

		<div class="divider"></div>

		<?php if($query != "") : ?>
			<?php
				$alpha_base_url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY";
				$alpha_api_key = "QUEJMT41CEQTOAWN";
				$alpha_url = $alpha_base_url."&symbol=".$query."&outputsize=full&apikey=".$alpha_api_key;
				//echo $alpha_url;
				//Local file for faster loading
				//$alpha_url = "alpha.json";
				
				$alpha_json = @file_get_contents($alpha_url);
				
				$parse_success;
				$error_msg = "";
				
				if ($alpha_json === FALSE){
					$parse_success = false;
					$error_msg = "Alpha Vantage API call failed, service unavaliable.";
				}else{				
					$alpha_json_obj = json_decode($alpha_json,true);
					
					$meta_tag = "Meta Data";
					if ( isset($alpha_json_obj[$meta_tag])  ){
						$parse_success = true;
					}else{
						$parse_success = false;					
						$error_msg = "Error: No record has been found, please enter a valid symbol";
					}
				}
				
			?>
			<?php if($parse_success) : ?>
				<?php
					$meta_data = $alpha_json_obj["Meta Data"];
					$time_series = $alpha_json_obj["Time Series (Daily)"];
					$date_keys = array_keys($time_series);
					$today_data = $time_series[$date_keys[0]];
					$yesterday_data = $time_series[$date_keys[1]];

					$green_arrow_up = "http://cs-server.usc.edu:45678/hw/hw6/images/Green_Arrow_Up.png"; 
					$red_arrow_down =  "http://cs-server.usc.edu:45678/hw/hw6/images/Red_Arrow_Down.png";
				?>

				<table  class="resultTable">
					<tr>
						<td class="leftCol">Stock Ticker Symbol</td>
						<td class="rightCol"><?php echo $meta_data["2. Symbol"] ?></td>
					</tr>
					<tr>
						<td class="leftCol">Close</td>
						<td class="rightCol"><?php echo $today_data["1. open"]?></td>
					</tr>
					<tr>
						<td class="leftCol">Open</td>
						<td class="rightCol"><?php echo $today_data["4. close"]?></td>
					</tr>
					<tr>
						<td class="leftCol">Previous Close</td>
						<td class="rightCol"><?php echo $yesterday_data["4. close"]?></td>
					</tr>
					<tr>
						<td class="leftCol">Change</td>
						<td class="rightCol">
							<?php
								$diff = $today_data["4. close"]-$yesterday_data["4. close"];
							  	echo number_format($diff,2,'.','');
							 ?>
							 <img class="arrow" src="
							 	<?php
							 		if ($diff >= 0) {
							 			echo $green_arrow_up;
							 		}else{
							 			echo $red_arrow_down;
							 		}
							 	?>
							 ">
						</td>
					</tr>
					<tr>
						<td class="leftCol">Change Percent</td>
						<td class="rightCol">
							<?php
								$percent = (($today_data["4. close"]-$yesterday_data["4. close"]) / $yesterday_data["4. close"]) * 100;
								echo number_format($percent,2,'.','')."%";
							?>
							<img class="arrow" src="
							 	<?php
							 		if ($percent >= 0) {
							 			echo $green_arrow_up;
							 		}else{
							 			echo $red_arrow_down;
							 		}
							 	?>
							 ">
						</td>
					</tr>
					<tr>
						<td class="leftCol">Day's Range</td>
						<td class="rightCol"><?php echo $today_data["3. low"]."-".$today_data["2. high"] ?></td>
					</tr>
					<tr>
						<td class="leftCol">Volume</td>
						<td class="rightCol"><?php echo number_format($today_data["5. volume"]) ?></td>
					</tr>
					<tr>
						<td class="leftCol">Timestamp</td>
						<td class="rightCol"><?php echo explode(" ",$meta_data["3. Last Refreshed"])[0] ?></td>
					</tr>
					<tr>
						<td class="leftCol">Indicators</td>
						<td class="rightCol">
							<span class="indicator"><a href="javascript:drawPriceChart()">Price</a></span>
							<span class="indicator"><a href="javascript:loadSMAChart()">SMA</a></span>
							<span class="indicator"><a href="javascript:loadEMAChart()">EMA</a></span>
							<span class="indicator"><a href="javascript:loadSTOCHChart()">STOCH</a></span>
							<span class="indicator"><a href="javascript:loadRSIChart()">RSI</a></span>
							<span class="indicator"><a href="javascript:loadADXChart()">ADX</a></span>
							<span class="indicator"><a href="javascript:loadCCIChart()">CCI</a></span>
							<span class="indicator"><a href="javascript:loadBBANDSChart()">BBANDS</a></span>
							<span class="indicator"><a href="javascript:loadMACDChart()">MACD</a></span>
						</td>
					</tr>
				</table>

				<div class="divider"></div>

				<?php
					//Prepare values for price chart
					
					$parsed_dates = [];
					$close_values = [];
					$volume_values = [];

					$last_date_split = explode("-",$date_keys[0]);
					$last_year = $last_date_split[0];
					$last_month = $last_date_split[1];
					$last_day = $last_date_split[2];
					
					$title_date = $last_month."/".$last_day."/".$last_year;

					///for ($i = 0;$i<130;$i++){					
					for ($i = 0;$i<count($date_keys);$i++){
						$a_day = $time_series[$date_keys[$i]];
						$current_date_split = explode("-",$date_keys[$i]);
						$current_month = $current_date_split[1];
						$current_day = $current_date_split[2];

						array_push($parsed_dates,substr($date_keys[$i],5,10));	
						array_push($close_values, floatval($a_day["4. close"]));
						array_push($volume_values, intval($a_day["5. volume"]));
						
						if (($current_month == $last_month-6) && ($current_day <= $last_day) && ($i % 5) == 0 ){
							break;
						}
						
					}

					$close_value_min = $close_values[0];
					$close_value_max = $close_values[0];
					$volume_value_min = $volume_values[0];
					$volume_value_max = $volume_values[0];

					for ($i = 1;$i<count($close_values);$i++ ){
						if ($close_values[$i] < $close_value_min){
							$close_value_min = $close_values[$i]; 
						}
						if ($close_values[$i] > $close_value_max){
							$close_value_max = $close_values[$i]; 
						}
						if ($volume_values[$i] < $volume_value_min){
							$close_value_min = $close_values[$i]; 
						}
						if ($volume_values[$i] > $volume_value_max){
							$volume_value_max = $volume_values[$i]; 
						}
					}

					$left_interval = floor(($close_value_max - $close_value_min) /5);
					$close_value_min = floor($close_value_min) - $left_interval;
					
					$left_tickers = [];
					for ($i = 0;$i<8;$i++){
						array_push($left_tickers,$close_value_min + $left_interval * $i );
					}
					//$close_value_max += $margin;
				
					$right_interval = ceil($volume_value_min) * 5;
					$right_tickers = [];
					for ($i = 0;$i<8;$i++){
						array_push($right_tickers,50000000 * $i );
					}


					$parsed_dates = array_reverse($parsed_dates);
					$close_values = array_reverse($close_values);
					$volume_values = array_reverse($volume_values);

				?>

				<script type="text/javascript">
					var sticker;
					var parsed_dates;
					var x_length;
					
					function drawPriceChart(){
						sticker = document.getElementById("queryText").value;
						var last_date = "<?php echo $date_keys[0] ?>";
						parsed_dates = <?php echo json_encode($parsed_dates) ?>;
						x_length = parsed_dates.length;
						var close_values = <?php echo json_encode($close_values) ?>;
						var volume_values =  <?php echo json_encode($volume_values) ?>;
						Highcharts.chart('chart-container', {
					        title: {
					            text: '<span style=\"font-size:14px\">Stock Price (' + "<?php echo $title_date ?>" + ")</span>",
					        },
					        subtitle:{
					        	text : '<a href="https://www.alphavantage.co/" class="bule-anchor" target="_blank">Source: Alpha Advantage</a>',
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
					        		tickPositions : <?php echo json_encode($left_tickers) ?>,
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
							        tickPositions : <?php echo json_encode($right_tickers) ?>,
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
							legend: {
								layout :  'vertical',
								align : 'right',
								verticalAlign :'middle'
							},
					        series: [{
					        	type : 'area',
					            name: sticker,
					            data: close_values,
					            color : '#d7606a'
					        },{
					        	yAxis : 1,
					        	type : 'column',
					        	name : sticker + "Volume",
					        	data : volume_values,
					        	color : '#FFF'
					        }]
					    });

					    document.getElementBy						
					}

					function yIntervalHelper(arr){
						var max = arr[0];
						var min = arr[1];
						for (var i=0;i<x_length;i++){
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

						/*
						var interval = Math.floor( (max-min) /5);
						min = Math.floor(min);
						min -= interval;
						var result = [];
						for (var i=0;i<8;i++){
							result.push(min + interval * i);
						}

						return result;
						*/
					}

					function drawSingleLineChart(data_json, acry){
						var root_keys = Object.keys(data_json);
						var ind_title = (data_json[root_keys[0]])["2: Indicator"];
						var data_series = data_json[root_keys[1]];
						var date_keys = Object.keys(data_series);
						var ind_acry =  Object.keys((data_json[root_keys[1]])[date_keys[0]])[0] ;
						
						var x_data = [];

						for (var i = 0;i<x_length;i++){
							x_data.unshift( parseFloat((data_series[date_keys[i]])[ind_acry]) );
						}

						var y_ticks = yIntervalHelper(x_data);
						
						Highcharts.chart('chart-container', {
					        title: {
					            text: '<span style=\"font-size:14px\">' + ind_title + '</span>',
					        },
					        subtitle:{
					     		text : '<a href="https://www.alphavantage.co/" class="bule-anchor" target="_blank">Source: Alpha Advantage</a>',
					        	useHTML : true
					        },
					        xAxis: {					        	
					            categories: parsed_dates,
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
							            text: acry,
							            style: {
							                color: Highcharts.getOptions().colors[1]
							            }
							        }
							    },
							legend: {
								layout :  'vertical',
								align : 'right',
								verticalAlign :'middle'
							},
					        series: [{
					        	type : 'line',
					            name: sticker,
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

					function drawDoubleLineChart(data_json, acry){
						var root_keys = Object.keys(data_json);
						var ind_title = (data_json[root_keys[0]])["2: Indicator"];
						var data_series = data_json[root_keys[1]];
						var date_keys = Object.keys(data_series);
						var ind_keys =  Object.keys((data_json[root_keys[1]])[date_keys[0]]) ;
						
						var x_data_0 = [];
						var x_data_1 = [];
						

						for (var i = 0;i<x_length;i++){
							x_data_0.unshift( parseFloat((data_series[date_keys[i]])[ind_keys[0]]));
							x_data_1.unshift( parseFloat((data_series[date_keys[i]])[ind_keys[1]]));
						}

						var y_ticks = yIntervalHelper(x_data_0);
						
						Highcharts.chart('chart-container', {
					        title: {
					            text: '<span style=\"font-size:14px\">' + ind_title + '</span>',
					        },
					        subtitle:{
					        	text : '<a href="https://www.alphavantage.co/" class="bule-anchor" target="_blank">Source: Alpha Advantage</a>',
					        	useHTML : true
					        },
					        xAxis: {					        	
					            categories: parsed_dates,
					            tickInterval : 5,
					            minorGridLineWidth: 0,
						        minorTickInterval: 'auto',
						        minorTickColor: '#d7606a',
						        minorTickWidth: 1
					        },
					        yAxis: { // Primary yAxis
					        		
							        labels: {
							            style: {
							                color: Highcharts.getOptions().colors[1]
							            }
							        },
							        title: {
							            text: acry,
							            style: {
							                color: Highcharts.getOptions().colors[1]
							            }
							        }
							    },
							legend: {
								layout :  'vertical',
								align : 'right',
								verticalAlign :'middle'
							},
					        series: [{
					        	type : 'line',
					            name: sticker + " " + ind_keys[0],
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
					            name: sticker + " " + ind_keys[1],
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

				function drawTripleLineChart(data_json, acry){
						var root_keys = Object.keys(data_json);
						var ind_title = (data_json[root_keys[0]])["2: Indicator"];
						var data_series = data_json[root_keys[1]];
						var date_keys = Object.keys(data_series);
						var ind_keys =  Object.keys((data_json[root_keys[1]])[date_keys[0]]) ;
						
						var x_data_0 = [];
						var x_data_1 = [];
						var x_data_2 = [];	

						for (var i = 0;i<x_length;i++){
							x_data_0.unshift( parseFloat((data_series[date_keys[i]])[ind_keys[0]]));
							x_data_1.unshift( parseFloat((data_series[date_keys[i]])[ind_keys[1]]));
							x_data_2.unshift( parseFloat((data_series[date_keys[i]])[ind_keys[2]]));
						}

						var y_ticks = yIntervalHelper(x_data_0);

						
						Highcharts.chart('chart-container', {
					        title: {
					            text: '<span style=\"font-size:14px\">' + ind_title + '</span>',
					        },
					        subtitle:{
					        	text : '<a href="https://www.alphavantage.co/" class="bule-anchor" target="_blank">Source: Alpha Advantage</a>',
					        	useHTML : true
					        },
					        xAxis: {					        	
					            categories: parsed_dates,
					            tickInterval : 5,
					            minorGridLineWidth: 0,
						        minorTickInterval: 'auto',
						        minorTickColor: '#d7606a',
						        minorTickWidth: 1
					        },
					        yAxis: { // Primary yAxis
					        		
							        labels: {
							            style: {
							                color: Highcharts.getOptions().colors[1]
							            }
							        },
							        title: {
							            text: acry,
							            style: {
							                color: Highcharts.getOptions().colors[1]
							            }
							        }
							    },
							legend: {
								layout :  'vertical',
								align : 'right',
								verticalAlign :'middle'
							},
					        series: [{
					        	type : 'line',
					            name: sticker + " " + ind_keys[0],
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
					            name: sticker + " " + ind_keys[1],
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
					            name: sticker + " " + ind_keys[2],
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

				</script>

				<div id="chart-container">
					
				</div>
					

				<?php
					$news_url = "https://seekingalpha.com/api/sa/combined/".$query.".xml";
					//echo $news_url;
					//$news_url = "AAPL.xml";

					$news_xml_object = simplexml_load_string(file_get_contents($news_url));
					
					$news_title = [];
					$news_link = [];
					$news_date = [];
					$parsed = 0;
					$item_index = 0;

					while ($parsed < 5){
						$a_item = $news_xml_object->channel->item[$item_index];
						if (strpos($a_item->link,"article") !== false ){
							array_push($news_title,$a_item->title);
							array_push($news_link,$a_item->link);
							array_push($news_date,substr($a_item->pubDate,0,25) );

							$parsed++;
						}
						$item_index++;
					}
				?>

				<script type="text/javascript">
					function showNews(){
						document.getElementById("showNews").style.display = "none";
						document.getElementById("hideNews").style.display = "block";
						document.getElementById("newsTable").style.display = "table";
					}
					function hideNews(){
						document.getElementById("showNews").style.display = "block";
						document.getElementById("hideNews").style.display = "none";
						document.getElementById("newsTable").style.display = "none";
					} 
					
				</script>

				<div class="showHideNews" id="showNews">
					<ul>
						<li><a href="javascript:showNews()">click to show stock news</a></li>
						<li><a href="javascript:showNews()"><img src="http://cs-server.usc.edu:45678/hw/hw6/images/Gray_Arrow_Down.png"></a></li>
					</ul>					
				</div>

				<div class="showHideNews" id="hideNews">
					<ul>
						<li><a href="javascript:hideNews()">click to hide stock news</a></li>
						<li><a href="javascript:hideNews()"><img src="http://cs-server.usc.edu:45678/hw/hw6/images/Gray_Arrow_Up.png"></a></li>
					</ul>					
				</div>

				<table id="newsTable" class="resultTable"></table>

				<script type="text/javascript">
					var news_title = <?php echo json_encode($news_title)?>;
					var news_link = <?php echo json_encode($news_link)?>;
					var news_date = <?php echo json_encode($news_date)?>;
					var table_text = "";


					for (var i=0;i<5;i++){
						table_text += "<tr class=\"newsRow\"><td><a href=\"" + news_link[i]["0"] + "\" target=\"_blank\">" + news_title[i]["0"] + "</a><span style=\"margin-left:20px\">Publicated Time: " + news_date[i] + "</span></td></tr>";
					} 
					document.getElementById("newsTable").innerHTML = table_text;

					hideNews();
				</script>


			<?php else : ?>
				<table class="resultTable">
					<tr>
						<td class="leftCol">Error</td>
						<td class="rightCol"><?php echo $error_msg ?></td>
					</tr>

				</table>
			
			<?php endif; ?>

		<?php endif; ?>

</body>



</html>