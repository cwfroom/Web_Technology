//
//  StockData.swift
//  stock-iOS
//
//  Created by Loli on 11/23/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import Foundation

class StockData{
    static let sharedInstance = StockData();
    
    public var currentSymbol : String;
    
    init() {
        currentSymbol = "AAPL";
    }
    
    
}
