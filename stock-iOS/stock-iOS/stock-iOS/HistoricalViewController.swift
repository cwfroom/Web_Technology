//
//  HistoricalController.swift
//  stock-iOS
//
//  Created by Loli on 11/24/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import UIKit
import WebKit

class HistoricalViewController: UIViewController{

    @IBOutlet weak var webView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        let anyGesture = UITapGestureRecognizer(target: self, action: #selector(self.getGesture(_:)));
        anyGesture.cancelsTouchesInView = false;
        self.view.addGestureRecognizer(anyGesture);
    }
    
    @objc func getGesture(_ recognizer : UIGestureRecognizer){
        print("Getting gesture in child view");
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let htmlPath = Bundle.main.path(forResource: "test", ofType: "html")
        let folderPath = Bundle.main.bundlePath
        let baseUrl = URL(fileURLWithPath: folderPath, isDirectory: true)
        //print(htmlPath ?? "??");
        //print(baseUrl);
        
        
        
        do {
            let htmlString = try NSString(contentsOfFile: htmlPath!, encoding: String.Encoding.utf8.rawValue)
            webView.loadHTMLString(htmlString as String, baseURL: baseUrl)
        } catch {
           
        }
        
        //webView.navigationDelegate = self
        
        super.viewWillAppear(animated);
    }
    
    func handleGesture(_ recognizer : UIGestureRecognizer){
        recognizer.cancelsTouchesInView = false;
        
        //self.webView.ges
        //recognizer
        //webView.addGestureRecognizer(<#T##gestureRecognizer: UIGestureRecognizer##UIGestureRecognizer#>)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
