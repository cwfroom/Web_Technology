//
//  CurrentViewController.swift
//  stock-iOS
//
//  Created by Loli on 11/24/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import UIKit

class CurrentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var currentTable: UITableView!
    @IBOutlet weak var indicatorPicker: UIPickerView!
    
    let data = StockData.sharedInstance;
    let prompts = ["Stock Symbol","Last Price","Change","Timestamp","Open","Close","Day's Range","Volume"];
    let indicators = ["Price","SMA","EMA","STOCH","RSI","ADX","CCI","BBANDS","MACD"];
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prompts.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentTableCell")!;
        
        cell.textLabel?.text = self.prompts[indexPath.row];
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold);
        
        cell.detailTextLabel?.text = data.currentDetail?.arr[indexPath.row];
        cell.detailTextLabel?.textAlignment = NSTextAlignment.left;
        
        return cell;
    }
    
    func reloadData(){
        DispatchQueue.main.async {
            self.currentTable.reloadData();
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return indicators.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel!
        if label == nil{
            label = UILabel();
        }
        let dataStr = indicators[row];
        
        let title = NSAttributedString(string: dataStr, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.regular)]);
        label?.attributedText = title;
        label?.textAlignment = .center;
        return label!;
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTable.delegate = self;
        currentTable.dataSource = self;
        indicatorPicker.delegate = self;
        indicatorPicker.dataSource = self;
        
        data.getPrice(currentView: self);
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
