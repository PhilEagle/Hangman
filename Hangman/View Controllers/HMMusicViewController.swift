//
//  HMMusicViewController.swift
//  Swift Hangman
//
//  Created by philippe eggel on 01/12/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import UIKit
import StoreKit

class HMMusicViewController: UITableViewController {

    private var musicInfos: [HMMusicInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "reload", forControlEvents: .ValueChanged)
        reload()
        refreshControl.beginRefreshing()
    }
    
    private func reload() {
        musicInfos = []
        tableView.reloadData()
        requestMusic()
    }
    
    private func requestMusic() {
        let url = NSURL(string: "https://itunes.apple.com/search?term=castlevania&media=music&entity=musicTrack&attribute=songTerm")!
        
        let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        session.dataTaskWithURL(url) { [weak self] (data, response, error) -> Void in
            
            guard let strongSelf = self else {
                return
            }
            
            if error == nil {
                
                do {
                    let searchResults = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String: AnyObject]
                    guard let results = searchResults["results"] as? [AnyObject] else {
                        print("No results available.")
                        return
                    }
                    
                    for result in results {
                        if let
                            info = result as? [String: AnyObject],
                            trackIdString = info["trackId"] as? Int,
                            trackName = info["trackName"] as? String,
                            artistName = info["artistName"] as? String,
                            price = info["trackPrice"] as? Float,
                            artworkURL = info["artworkUrl60"] as? String {
                                
                                let musicInfo = HMMusicInfo(trackId: trackIdString, trackName: trackName, artistName: artistName, price: price, artworkURL: artworkURL)
                                strongSelf.musicInfos.append(musicInfo)
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
                        
                        guard let strongSelf = self else {
                            return
                        }
                        
                        strongSelf.tableView.reloadData()
                    })
                    
                    strongSelf.refreshControl?.endRefreshing()
                    
                } catch let parseError as NSError {
                    print("Failed to parse response: \(parseError.localizedDescription)")
                    strongSelf.refreshControl?.endRefreshing()
                }
                
            } else {
                
                print("Error searching for song: \(error?.localizedDescription)")
                strongSelf.refreshControl?.endRefreshing()
                
            }
            
        }.resume()
        
    }
    
    
    //MARK: - TableView data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicInfos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "Cell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! HMMusicCell
        let info = musicInfos[indexPath.row]
        
        cell.titleLabel.text = info.trackName
        cell.descriptionLabel.text = info.artistName
        cell.priceLabel.text = String(format: "$%0.2f", info.price)
        cell.iconImageView.image = UIImage(named: "icon_placeholder.png")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            guard let url = NSURL(string: info.artworkURL), data = NSData(contentsOfURL: url) else {
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                guard let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? HMMusicCell else {
                    return
                }
                
                cellToUpdate.iconImageView.image = UIImage(data: data)
            })
        }
        
        return cell
    }
    
    
    //MARK: - TableView delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let info = musicInfos[indexPath.row]
        
        ProgressHUD.show("Loading...")
        
        let viewController = SKStoreProductViewController()
        viewController.delegate = self
        let parameters = [SKStoreProductParameterITunesItemIdentifier: info.trackId]
        
        viewController.loadProductWithParameters(parameters) { [weak self] (result, error) -> Void in
            
            ProgressHUD.dismiss()
            
            guard let strongSelf = self else {
                return
            }
            
            if result {
                strongSelf.presentViewController(viewController, animated: true, completion: nil)
            } else {
                print("Failed to load products: \(error?.localizedDescription)")
            }
            
        }
        
    }
    
    
}

//MARK: - Music Store
extension HMMusicViewController: SKStoreProductViewControllerDelegate {
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        print("Finished shopping!")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

