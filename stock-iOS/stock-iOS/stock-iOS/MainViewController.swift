//
//  ViewController.swift
//  stock-iOS
//
//  Created by Loli on 11/20/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var sortbyPicker: UIPickerView!
    @IBOutlet weak var orderbyPicker: UIPickerView!
    
    let sortByData = ["Default","Symbol","Price","Change","Percent"];
    let orderByData = ["Ascending","Desceding"];
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == self.sortbyPicker){
            return self.sortByData.count;
        }else if(pickerView == self.orderbyPicker){
            return self.orderByData.count;
        }else{
            return 0;
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == self.sortbyPicker){
            return sortByData[row];
        }else if(pickerView == self.orderbyPicker){
            return orderByData[row];
        }else{
            return "";
        }
    }
 
 
 
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel!
        if label == nil{
            label = UILabel();
        }
        var dataStr = "";
        if (pickerView == self.sortbyPicker){
            dataStr =  sortByData[row];
        }else if(pickerView == self.orderbyPicker){
            dataStr = orderByData[row];
        }
        
        let title = NSAttributedString(string: dataStr, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.regular)]);
        label?.attributedText = title;
        label?.textAlignment = .center;
        return label!;
        
    }
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.sortbyPicker.delegate = self;
        self.sortbyPicker.dataSource = self;
        self.orderbyPicker.delegate = self;
        self.orderbyPicker.dataSource = self;
        //initializePickers();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializePickers(){
        
    }
    
    


}

