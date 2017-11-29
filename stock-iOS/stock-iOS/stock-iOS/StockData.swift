//
//  StockData.swift
//  stock-iOS
//
//  Created by Loli on 11/23/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import Foundation
import UIKit

//Helper Structs
struct NewsItem {
    let title,link,author,date : String;
}

extension NewsItem{
    init?(json : [String : Any]){
        let title = json["title"] as! String;
        let link = json["link"] as! String;
        let author = json["author"] as! String;
        let date = json["date"] as! String;
      
        self.title = title;
        self.link = link;
        self.author = author;
        self.date = date;
    }
}

struct FavItem{
    var symbol,changeStr : String;
    var price,change,changePercent : Float;
    var volume : Int;
}

extension FavItem{
    init?(symbol : String, price : Float, change : Float, changePercent : Float, volume : Int){
        self.symbol = symbol;
        self.price = price;
        self.change = change;
        self.changePercent = changePercent;
        self.volume = volume;
        self.changeStr = "";
    }
}

struct DetailItem{
    let symbol,lastPrice,change,changePercent,timestamp,open,close,range,volume : String;
    let arr : [String];
}

extension DetailItem{
    init?(json : [String : Any]){
        let symbol = json["symbol"] as! String;
        let lastPrice = json["last_price"] as! String;
        let change = json["change"] as! String;
        let changePercent = json["change_percent"] as! String;
        let timestamp = json["timestamp"] as! String;
        let open = json["open"] as! String;
        let close = json["close"] as! String;
        let range = json["range"] as! String;
        let volume = json["volume"] as! String;
        
        self.symbol = symbol;
        self.lastPrice = lastPrice;
        self.change = change;
        self.changePercent = changePercent;
        self.timestamp = timestamp;
        self.open = open;
        self.close = close;
        self.range = range;
        self.volume = volume;
        
        let changeStr = change + "(" + changePercent + ")";
        
        self.arr = [symbol,lastPrice,changeStr,timestamp,open,close,range,volume];
        
    }
}
 


class StockData{
    static let sharedInstance = StockData();
    
    let serverAddr = "http://127.0.0.1:8000";
    
    public var currentSymbol : String;
    public var currentIsFav : Bool = false;
    
    var currentDetail : DetailItem?;
    var NewsList : [NewsItem] = [];
    var FavList : [FavItem] = [];
    
    init() {
        currentSymbol = "AAPL";
    }
    
    func updateData(){
        //getPrice();
        //getNews();
    }
    
    func getPriceURL() -> String{
        return serverAddr + "/price/" + currentSymbol;
    }
    
    func getPriceFastURL() -> String{
        return serverAddr + "/pricefast/" + currentSymbol;
    }
    
    func getPriceRawURL() -> String{
        return serverAddr + "/priceraw/" + currentSymbol;
    }
    
    func getIndicatorURL(indicator : String) -> String{
        return serverAddr + "/indicator/" + currentSymbol + "/" + indicator;
    }
    
    func getNewsURL() -> String{
        return serverAddr + "/news/" + currentSymbol;
    }
    
    func getPrice(currentView : CurrentViewController){
        let requestURL = URL(string: self.getPriceURL());
        
        let task = URLSession.shared.dataTask(with: requestURL!) { data, response, error in
            guard error == nil else {
                print(error!)
                return;
            }
            guard let data = data else {
                print("Data is empty");
                return;
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            if let json = json as? [String : Any]{
                if let jTable = json["table"] as? [String : Any]{
                    self.currentDetail = DetailItem(json: jTable);
                }
            }
            currentView.reloadData();
            
        }
        task.resume();
        
    }
    
    
    func getNews(newsTable : NewsViewController){
        NewsList = [];
        let requestURL = URL(string: self.getNewsURL());
        let task = URLSession.shared.dataTask(with: requestURL!) { data, response, error in
            guard error == nil else {
                print(error!)
                return;
            }
            guard let data = data else {
                print("Data is empty");
                return;
            }
            let json = try! JSONSerialization.jsonObject(with: data, options: []);
            if let jNewsArray = json as? [Any]{
                for jNews in jNewsArray {
                    if let iNewsItem = NewsItem(json:jNews as! [String : Any]){
                        self.NewsList.append(iNewsItem);
                    }
                }
            }
            
            newsTable.reloadData();
        }
        task.resume();
    }
    
    func changeFav(ui : CurrentViewController){
        if (currentIsFav){
            removeFav(symbol: currentSymbol);
        }else{
            addFav();
        }
        currentIsFav = !currentIsFav;
        ui.checkFavButton();
    }
    
    func addFav(){
        //To float
        //let price = currentDetail?.lastPrice;
    }
    
    func removeFav(symbol : String){
        
    }
    
}
