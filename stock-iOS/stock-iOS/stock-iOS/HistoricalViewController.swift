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
    let data = StockData.sharedInstance;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        let htmlPath = Bundle.main.path(forResource: "historical", ofType: "html")
        let folderPath = Bundle.main.bundlePath
        let baseUrl = URL(fileURLWithPath: folderPath, isDirectory: true)
        
        let jsURL = "<script>var apiURL = \"" + self.data.getPriceRawURL() +  "\"</script>"
        
        do {
            let html = try String(contentsOfFile: htmlPath!);
            let htmlString = jsURL + html;
            webView.loadHTMLString(htmlString as String, baseURL: baseUrl)
        } catch {
            print("HTML cannot be loaded");
        }
    }
    
    func handleGesture(_ recognizer : UIGestureRecognizer){
        recognizer.cancelsTouchesInView = false;
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
