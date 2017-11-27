//
//  DetailsViewController.swift
//  stock-iOS
//
//  Created by Loli on 11/23/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var segControl: UISegmentedControl!
    
    let data = StockData.sharedInstance;
    
    @objc func back(){
        self.dismiss(animated:true, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segControl.addTarget(self,action: #selector(selectionDidChange(_:)), for: .valueChanged);
        segControl.selectedSegmentIndex = 0;
        add(asChildViewController: currentViewController);
        
         let anyGesture = UITapGestureRecognizer(target: self, action: #selector(self.getGesture(_:)));
        anyGesture.cancelsTouchesInView = false;
        self.view.addGestureRecognizer(anyGesture);
    }
    
    @objc func getGesture(_ recognizer : UIGestureRecognizer){
       
        if (segControl.selectedSegmentIndex == 1){
            //historicalViewController.handleGesture(recognizer);
        }else if (segControl.selectedSegmentIndex == 2){
            newsViewController.handleGesture(recognizer);
        }
    }
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        if (segControl.selectedSegmentIndex == 0){
            remove(asChildViewController: historicalViewController);
            remove(asChildViewController: newsViewController);
            add(asChildViewController: currentViewController);
        }else if (segControl.selectedSegmentIndex == 1){
            remove(asChildViewController: currentViewController);
            remove(asChildViewController: newsViewController);
            add(asChildViewController: historicalViewController);
        }else if (segControl.selectedSegmentIndex == 2){
            remove(asChildViewController: currentViewController);
            remove(asChildViewController: historicalViewController);
            add(asChildViewController: newsViewController);
        }
    }
    
    private lazy var currentViewController: CurrentViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main);
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "CurrentViewController") as! CurrentViewController
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var historicalViewController: HistoricalViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main);
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "HistoricalViewController") as! HistoricalViewController
        
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var newsViewController: NewsViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main);
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "NewsViewController") as! NewsViewController
        
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    
    
    
    private func add(asChildViewController viewController: UIViewController) {
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        //viewController.view.frame = view.bounds
        //viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false;
        
        let verticalConstraint = NSLayoutConstraint(item: viewController.view, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.segControl, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 5);
        let horizontalConstraint = NSLayoutConstraint(item: viewController.view, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        
        let widthConstraint = NSLayoutConstraint(item: viewController.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: viewController.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
        
        
        view.addConstraint(verticalConstraint);
        view.addConstraint(horizontalConstraint);
        view.addConstraint(widthConstraint);
        view.addConstraint(heightConstraint);
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
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
