//
//  DetailsViewController.swift
//  stock-iOS
//
//  Created by Loli on 11/23/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    //@IBOutlet weak var navItem: UINavigationItem!
    let data = StockData.sharedInstance;
    
    @objc func back(){
        self.dismiss(animated:true, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        let backButton : UIBarButtonItem = UIBarButtonItem(title:"Back",style:.done,target:self,action:#selector(back));
        navItem.leftBarButtonItem = backButton;
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = data.currentSymbol;
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
