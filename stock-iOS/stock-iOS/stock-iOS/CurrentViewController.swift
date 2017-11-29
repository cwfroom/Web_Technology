//
//  CurrentViewController.swift
//  stock-iOS
//
//  Created by Loli on 11/24/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import UIKit
import WebKit

class CurrentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var currentTable: UITableView!
    @IBOutlet weak var indicatorPicker: UIPickerView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var changeButton: UIButton!
    
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var FBButton: UIButton!
    
    let data = StockData.sharedInstance;
    let prompts = ["Stock Symbol","Last Price","Change","Timestamp","Open","Close","Day's Range","Volume"];
    let indicators = ["Price","SMA","EMA","STOCH","RSI","ADX","CCI","BBANDS","MACD"];
    let indicatorLines = [0,1,1,2,1,1,1,3,3];
    var currentIndex : Int = 0;
    
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (row != currentIndex){
            self.changeButton.isEnabled = true;
        }
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width,height:1000);
        self.indicatorPicker.selectRow(0, inComponent: 0, animated: false);
        loadPriceChart();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        checkFavButton();
        changeButton.isEnabled = false;
    }

    @IBAction func changeButtonTouch(_ sender: Any) {
        let index = self.indicatorPicker.selectedRow(inComponent: 0);
        if (index == 0){
            loadPriceChart();
        }else{
            loadIndicatorChart(index: index);
        }
        currentIndex = index;
        self.changeButton.isEnabled = false;
    }
    
    @IBAction func favButtonTouch(_ sender: Any) {
        data.changeFav(ui:self);
    }
    
    func checkFavButton(){
        if (data.currentIsFav){
            self.favButton.setImage(UIImage(named:"Star"), for: UIControlState.normal);
        }else{
            self.favButton.setImage(UIImage(named:"StarEmpty"), for: UIControlState.normal);
        }
    }
    
    func loadPriceChart(){
        let htmlPath = Bundle.main.path(forResource: "price", ofType: "html")
        let folderPath = Bundle.main.bundlePath
        let baseUrl = URL(fileURLWithPath: folderPath, isDirectory: true)
        
        let jsURL = "<script>var apiURL = \"" + self.data.getPriceURL() +  "\"</script>"
        
        do {
            let html = try String(contentsOfFile: htmlPath!);
            let htmlString = jsURL + html;
            webView.loadHTMLString(htmlString as String, baseURL: baseUrl)
        } catch {
            print("HTML cannot be loaded");
        }
    }
    

    func loadIndicatorChart(index : Int){
        let htmlPath = Bundle.main.path(forResource: "indicator", ofType: "html")
        let folderPath = Bundle.main.bundlePath
        let baseUrl = URL(fileURLWithPath: folderPath, isDirectory: true)
        
        let jsURL = "<script>var apiURL = \"" + self.data.getIndicatorURL(indicator: indicators[index]) + "\";var lines=" + String(indicatorLines[index]) + ";</script>";
        
        //print(jsURL);
        
        
        do {
            let html = try String(contentsOfFile: htmlPath!);
            let htmlString = jsURL + html;
            webView.loadHTMLString(htmlString as String, baseURL: baseUrl)
        } catch {
            print("HTML cannot be loaded");
        }
        
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
