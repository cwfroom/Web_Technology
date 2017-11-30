//
//  HistoricalController.swift
//  stock-iOS
//
//  Created by Loli on 11/24/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import UIKit
import WebKit

class HistoricalViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler{


    let data = StockData.sharedInstance;
    
    var chartView : WKWebView = WKWebView();
    @IBOutlet weak var chartPlaceHolder: UIView!
    @IBOutlet weak var chartActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = WKWebViewConfiguration();
        config.userContentController.add(self,name:"interOp");
        chartView = WKWebView(frame:chartPlaceHolder.frame,configuration: config);
        chartView.navigationDelegate = self;
        view.addSubview(chartView);
        errorLabel.isHidden = true;
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        if (data.isError){
            chartView.isHidden = true;
            errorLabel.isHidden = false;
        }else{
            errorLabel.isHidden = true;
            loadHistoricalChart();
        }
    }
    
    func loadHistoricalChart(){
        let htmlPath = Bundle.main.path(forResource: "historical", ofType: "html")
        let folderPath = Bundle.main.bundlePath
        let baseUrl = URL(fileURLWithPath: folderPath, isDirectory: true)
        
        let jsURL = "<script>var apiURL = \"" + self.data.getPriceRawURL() +  "\"</script>"
        
        DispatchQueue.main.async {
            self.chartView.isHidden = true;
            self.chartActivityIndicator.startAnimating();
            do {
                let html = try String(contentsOfFile: htmlPath!);
                let htmlString = jsURL + html;
                self.chartView.loadHTMLString(htmlString as String, baseURL: baseUrl)
            } catch {
                print("HTML cannot be loaded");
            }
        }
    }
    

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.body as! String == "finish"){
            print("Webview finished loading");
            DispatchQueue.main.async {
                self.chartView.isHidden = false;
                self.chartActivityIndicator.stopAnimating();
            }
        }
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
