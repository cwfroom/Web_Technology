//
//  ViewController.swift
//  stock-iOS
//
//  Created by Loli on 11/20/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import UIKit
import Toast_Swift

class MainViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var sortbyPicker: UIPickerView!
    @IBOutlet weak var orderbyPicker: UIPickerView!
    @IBOutlet weak var favTable: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshSwitch: UISwitch!
    @IBOutlet weak var symbolTextField: UITextField!
    @IBOutlet weak var autoCompleteTable: UITableView!
    @IBOutlet weak var getQuoteButton: UIButton!
    
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
    }
    
    //Tables
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == favTable){
            return data.FavList.count;
        }else if (tableView == autoCompleteTable){
            return data.AutoCompleteList.count;
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == favTable){
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
        }else if(tableView == autoCompleteTable){
            let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompleteTableCell")!
            cell.textLabel?.text = data.AutoCompleteList[indexPath.row].display;
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14);
            return cell;
        }
        
        return UITableViewCell();
        
    }
  
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == favTable){
            data.currentSymbol = data.FavList[indexPath.row].symbol;
            performSegue(withIdentifier: "showDetails", sender: getQuoteButton);
        }else if (tableView == autoCompleteTable){
            self.symbolTextField.text = data.AutoCompleteList[indexPath.row].value;
            self.symbolTextField.endEditing(true);
            hideAutoComplete();
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (tableView == favTable){
            if (editingStyle == .delete){
                data.removeFav(index: indexPath.row);
                tableView.reloadData();
            }
        }
        
    }

    func reloadFavTable(){
        DispatchQueue.main.async {
            self.favTable.reloadData();
        }
    }
    
    func reloadAutoCompleteTable(){
        DispatchQueue.main.async {
            self.autoCompleteTable.reloadData();
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
    
    func showAutoComplete(){
        autoCompleteTable.isHidden = false;
    }
    
    func hideAutoComplete(){
        autoCompleteTable.isHidden = true;
    }
    
    @IBAction func symbolEditChange(_ sender: Any) {
        let query = self.symbolTextField.text!;
        let whitespaceSet = CharacterSet.whitespaces
        if (query != "" && !query.trimmingCharacters(in: whitespaceSet).isEmpty) {
            print(query);
            showAutoComplete();
            data.getAutoComplete(query: query, ui: self);
        }else{
            hideAutoComplete();
        }
        
    }
    
    
    @IBAction func clearButtonTouch(_ sender: Any) {
        symbolTextField.text = "";
        hideAutoComplete();
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
        self.autoCompleteTable.delegate = self;
        self.autoCompleteTable.dataSource = self;
        self.autoCompleteTable.alpha = 0.8;
        self.autoCompleteTable.isHidden = true;
        
        //To lazy to type
        self.symbolTextField.text = "AAPL";
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.getTap(_:)));
        view.addGestureRecognizer(tap)
    }
    
    @objc func getTap(_ tap : UIGestureRecognizer) {
        let tapLocation = tap.location(in: autoCompleteTable);
        if (!autoCompleteTable.isHidden){
            let indexPath = autoCompleteTable.indexPathForRow(at: tapLocation);
            if (indexPath != nil){
                self.symbolTextField.endEditing(true);
                self.symbolTextField.text = data.AutoCompleteList[(indexPath?.row)!].value;
                hideAutoComplete();
            }else{
                hideAutoComplete();
            }
        }else{
            symbolTextField.endEditing(true);
        }
        
        /*
        let indexPath = favTable.indexPathForRow(at: tapLocation);
        if (indexPath != nil){
            print("favtable");
            favTable.selectRow(at: indexPath, animated: true, scrollPosition: .none);
        }
        */
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
        let query = self.symbolTextField.text!;
        let whitespaceSet = CharacterSet.whitespaces
        if (query != "" && !query.trimmingCharacters(in: whitespaceSet).isEmpty) {
            data.currentSymbol = query;
            performSegue(withIdentifier: "showDetails", sender: sender);
        }else{
            view.makeToast("Please enter a valid symbol",duration:2.0,position:.center);
        }
        
        
        
    }
    


}

