//
//  ViewController.swift
//  stock-iOS
//
//  Created by Loli on 11/20/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var sortbyPicker: UIPickerView!
    @IBOutlet weak var orderbyPicker: UIPickerView!
    @IBOutlet weak var favTable: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshSwitch: UISwitch!
    
    var data = StockData.sharedInstance;
    var autoRefreshTimer = Timer();
    
    //UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == self.sortbyPicker){
            return self.data.sortByData.count;
        }else if(pickerView == self.orderbyPicker){
            return self.data.orderByData.count;
        }else{
            return 0;
        }
    }
    
    /*
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == self.sortbyPicker){
            return sortByData[row];
        }else if(pickerView == self.orderbyPicker){
            return orderByData[row];
        }else{
            return "";
        }
    }
 */
 
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel!
        if label == nil{
            label = UILabel();
        }
        var dataStr = "";
        if (pickerView == self.sortbyPicker){
            dataStr = data.sortByData[row];
        }else if(pickerView == self.orderbyPicker){
            dataStr = data.orderByData[row];
        }
        
        let title = NSAttributedString(string: dataStr, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.regular)]);
        label?.attributedText = title;
        label?.textAlignment = .center;
        return label!;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let sortby = self.sortbyPicker.selectedRow(inComponent: 0);
        if (sortby != 0){
            self.orderbyPicker.isUserInteractionEnabled = true;
        }else{
            self.orderbyPicker.isUserInteractionEnabled = false;
        }
        
        let orderby = self.orderbyPicker.selectedRow(inComponent: 0);
        
        data.sortFavList(sortby: sortby, orderby: orderby, ui: self);
        //print (sortby + " " + orderby )
    }
    
    //FavTable
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.FavList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavTableCell")! as! FavTableCell;
        cell.symbolLabel.text = data.FavList[indexPath.row].symbol;
        cell.priceLabel.text = String(data.FavList[indexPath.row].price);
        cell.changeLabel.text = data.FavList[indexPath.row].changeStr;
        if (data.FavList[indexPath.row].change >= 0){
            cell.changeLabel.textColor = UIColor.green;
        }else{
            cell.changeLabel.textColor = UIColor.red;
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        data.currentSymbol = data.FavList[indexPath.row].symbol;
        performSegue(withIdentifier: "showDetails", sender: self);
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete){
            data.removeFav(index: indexPath.row);
            tableView.reloadData();
        }
    }

    func reloadData(){
        DispatchQueue.main.async {
            self.favTable.reloadData();
        }
    }
    
    @objc func updateFav(){
        data.updateFav(ui:self);
    }
    
    @IBAction func refreshButtonTouch(_ sender: Any) {
        updateFav();
    }
    
    @IBAction func refreshSwitchChange(_ sender: Any) {
        if (self.refreshSwitch.isOn){
            startAutoRefresh();
        }else{
            stopAutoRefresh();
        }
    }
    
    func startAutoRefresh(){
        autoRefreshTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateFav), userInfo: nil, repeats: true)
    }
    
    func stopAutoRefresh(){
        autoRefreshTimer.invalidate();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Pickers
        self.sortbyPicker.delegate = self;
        self.sortbyPicker.dataSource = self;
        self.orderbyPicker.delegate = self;
        self.orderbyPicker.dataSource = self;
        self.orderbyPicker.isUserInteractionEnabled = false;
        self.favTable.delegate = self;
        self.favTable.dataSource = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        self.favTable.reloadData();
        super.viewWillAppear(animated);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func getQuoteButtonTouch(_ sender: Any) {
        performSegue(withIdentifier: "showDetails", sender: sender);
        
    }
    


}

