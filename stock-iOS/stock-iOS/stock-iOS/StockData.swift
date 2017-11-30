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
    let symbol,changeStr : String;
    let price,change,changePercent : Float;
    let volume : Int;
}

extension FavItem{
    init(json : [String : Any]) {
        
        let symbol = json["symbol"] as! String;
        let price = Float(json["price"] as! String)!;
        let change = Float(json["change"] as! String)!;
        let changePercent = Float((json["changePercent"] as! String).replacingOccurrences(of: "%", with: ""))!;
        let volume = Int(json["volume"] as! String)!;
        
        self.symbol = symbol;
        self.price = price;
        self.change = change;
        self.changePercent = changePercent;
        self.volume = volume;
        self.changeStr = (json["change"] as! String) + "(" + (json["changePercent"] as! String) + ")";
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

struct AutoCompleteItem{
    let value : String;
    let display : String;
}

extension AutoCompleteItem{
    init?(json : [String : Any]) {
        let value = json["value"] as! String;
        let display = json["display"] as! String;
        self.value = value;
        self.display = display;
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
    var defaultOrder : [FavItem] = [];
    var AutoCompleteList : [AutoCompleteItem] = [];
    
    let sortByData = ["Default","Symbol","Price","Change","Percent"];
    let orderByData = ["Ascending","Descending"];
    
    init() {
        currentSymbol = "AAPL";
        //For debugging
        let A = FavItem(symbol: "AAPL", changeStr: "1(10%)", price: 100, change: 1, changePercent: 0.1, volume: 100);
        let B = FavItem(symbol: "AMZN", changeStr: "2(5%)", price: 150, change: 2, changePercent: 0.05, volume: 50);
        FavList.append(A);
        FavList.append(B);
        defaultOrder = FavList;
    }
    
    
    func getPriceURL() -> String{
        return serverAddr + "/price/" + currentSymbol;
    }
    
    func getPriceFastURL(symbol: String) -> String{
        return serverAddr + "/pricefast/" + symbol;
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
    
    func getAutoCompleteURL(query : String) -> String{
        return serverAddr + "/autocomplete/" + query;
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
        let price = Float(currentDetail!.lastPrice)!;
        let change = Float(currentDetail!.change)!;
        let changePercent = Float(currentDetail!.changePercent.replacingOccurrences(of: "%", with: ""))!;
        let volume = Int(currentDetail!.volume)!;
        let changeStr = currentDetail!.change + "(" + currentDetail!.changePercent + ")";
        
        let fav = FavItem(symbol: currentSymbol, changeStr: changeStr, price: price, change: change, changePercent: changePercent, volume: volume);
        FavList.append(fav);
        defaultOrder = FavList;
    }
    
    func removeFav(symbol : String){
        var index : Int = 0;
        for fav in FavList{
            if (fav.symbol == symbol){
                break;
            }
            index += 1;
        }
        
        FavList.remove(at: index);
        defaultOrder = FavList;
    }
    
    func removeFav(index : Int){
        FavList.remove(at: index);
        defaultOrder = FavList;
    }
    
    func updateFav(ui : MainViewController){
        let originalCount = FavList.count;
        getPriceFast(index: 0, count: originalCount, ui: ui);
    }
    
    
    func getPriceFast(index : Int, count: Int, ui : MainViewController){
        let requestURL = URL(string: self.getPriceFastURL(symbol: FavList[index].symbol));
        
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
                let fav = FavItem(json:json);
                self.FavList.append(fav);
                
                if (index < count - 1 ){
                    self.getPriceFast(index: index + 1, count: count, ui: ui);
                }else{
                    self.FavList.removeFirst(count);
                    ui.reloadFavTable();
                }
            }

            
        }
        task.resume();
    }
    
    func sortFavList(sortby : Int, orderby : Int, ui:MainViewController){
        var asc : Bool = true;
        if (orderby == 0){
            asc = true;
        }else if(orderby == 1){
            asc = false;
        }
        //["Default","Symbol","Price","Change","Percent"];
        
        switch sortby {
        case 0:
            FavList = defaultOrder;
            break;
        case 1:
            if (asc){
                FavList.sort{$0.symbol < $1.symbol};
            }else{
                FavList.sort{$0.symbol > $1.symbol};
            }
            break;
        case 2:
            if (asc){
                FavList.sort{$0.price < $1.price}
            }else{
                FavList.sort{$0.price > $1.price}
            }
            break;
        case 3:
            if (asc){
                FavList.sort{$0.change < $1.change}
            }else{
                FavList.sort{$0.change > $1.change}
            }
            break;
        case 4:
            if (asc){
                FavList.sort{$0.changePercent < $1.changePercent}
            }else{
                FavList.sort{$0.changePercent > $1.changePercent}
            }
            break;
        default:
            break;
        }
        
        ui.reloadFavTable();
    }
    
    func getAutoComplete(query : String, ui : MainViewController){
        AutoCompleteList = [];
        let requestURL = URL(string: self.getAutoCompleteURL(query: query));
        let task = URLSession.shared.dataTask(with: requestURL!) { data, response, error in
            guard error == nil else {
                print(error!)
                return;
            }
            guard let data = data else {
                print("Data is empty");
                return;
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: []);
                
                if let jAutoCompleteArray = json as? [Any]{
                    var count :Int  = 0;
                    for jAutoComplete in jAutoCompleteArray {
                        if (count >= 5){
                            break;
                        }
                        if let iAutoCompleteItem = AutoCompleteItem(json:jAutoComplete as! [String : Any]){
                            self.AutoCompleteList.append(iAutoCompleteItem);
                        }
                        count += 1;
                    }
                }
            }catch{
                print("Error in AutoComplete");
            }

            ui.reloadAutoCompleteTable();
            
        }
        task.resume();
    }
    
}
