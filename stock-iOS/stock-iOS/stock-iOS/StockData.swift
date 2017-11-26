//
//  StockData.swift
//  stock-iOS
//
//  Created by Loli on 11/23/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import Foundation


//Helper Structs
struct NewsItem {
    let title : String;
    let link : String;
    let author: String;
    let date : String;
}

extension NewsItem{
    init?(json : [String : Any]){
        guard let title = json["title"] as? String,
        let link = json["link"] as? String,
        let author = json["author"] as? String,
        let date = json["data"] as? String
        else{
            return nil;
        }
        self.title = title;
        self.link = link;
        self.author = author;
        self.date = date;
    }
}


class StockData{
    static let sharedInstance = StockData();
    
    let serverAddr = "http://127.0.0.1:8000";
    
    public var currentSymbol : String;
    

    var NewsList : [NewsItem] = [];
    
    
    init() {
        currentSymbol = "AAPL";
    }
    
    func updateData(){
        //getPrice();
        getNews();
    }
    
    func getPrice(){
        let requestURL = URL(string: serverAddr + "/price/" + currentSymbol);
        
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
            print(json)
        }
        
        task.resume();
        

    }
    
    func parsePrice(){
    
    }
    
    func getNews(){
        let requestURL = URL(string: serverAddr + "/news/" + currentSymbol);
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
            
        }
        task.resume();
    }
    
}
