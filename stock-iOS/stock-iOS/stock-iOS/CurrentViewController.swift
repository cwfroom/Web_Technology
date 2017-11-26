//
//  CurrentViewController.swift
//  stock-iOS
//
//  Created by Loli on 11/24/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import UIKit

class CurrentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var currentTable: UITableView!
    
    let data = StockData.sharedInstance;
    let prompts = ["Stock Symbol","Last Price","Change","Timestamp","Open","Close","Day's Range","Volume"];
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentTableCell")!;
        let promptLabel = UILabel(frame: CGRect(x:0,y:0,width:200,height:20));
        promptLabel.text = self.prompts[indexPath.row];
        
        cell.textLabel?.text = self.prompts[indexPath.row];
        
        cell.detailTextLabel?.text = "123123";
        //UILabel promptLabel = new UILabel();
        
        return cell;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTable.delegate = self;
        currentTable.dataSource = self;
        

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
