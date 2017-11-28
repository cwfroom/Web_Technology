//
//  NewsViewController.swift
//  stock-iOS
//
//  Created by Loli on 11/24/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
     var data = StockData.sharedInstance;
    
    @IBOutlet weak var newsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTable.delegate = self;
        newsTable.dataSource = self;
        newsTable.setEditing(false, animated: false);
        newsTable.allowsSelection = true;
    }
    
    func handleGesture(_ recognizer : UIGestureRecognizer){
        let tapLocation = recognizer.location(in: self.newsTable);
        let indexPath = self.newsTable.indexPathForRow(at: tapLocation);
        if (indexPath != nil){
            self.newsTable.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none);
            openNewsLink(index: (indexPath?.row)!);
            self.newsTable.deselectRow(at: indexPath!, animated: true);
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        data.getNews(newsTable: self);
        super.viewDidAppear(animated);
    }
    
    func reloadData(){
        DispatchQueue.main.async {
            self.newsTable.reloadData();
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.NewsList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableCell")!;
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold);
        cell.textLabel?.text = data.NewsList[indexPath.row].title;
        
        cell.detailTextLabel?.numberOfLines = 0;
        cell.detailTextLabel?.textColor = UIColor.gray;
        cell.detailTextLabel?.text = " Author: " + data.NewsList[indexPath.row].author + "\n\n Date: " + data.NewsList[indexPath.row].date;
        
        return cell;
    }
    
    func openNewsLink(index : Int){
        let newsLink = URL(string : data.NewsList[index].link);
        UIApplication.shared.open(newsLink!, options: [:], completionHandler:nil);
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let link = data.NewsList[indexPath.row].link;
        let newsLink = URL(string: link);
        UIApplication.shared.open(newsLink!, options: [:], completionHandler:nil);
        
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
