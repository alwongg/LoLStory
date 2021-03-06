//
//  ChampionsViewController.swift
//  iLoL
//
//  Created by Alex Wong on 8/2/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import UIKit

// MARK: - ChampionsViewController

class ChampionsViewController: UIViewController {
    
    // MARK: - Properties
    
    var champions = [ChampionDetails]()
    var store: ChampionStorage!
    
    // MARK: - IBOutlets
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change the font to BradleyHandITCTT-Bold
        
        configUI()
        
        // Get and display champions
        
        store.getChampionData {(championsResult) -> Void in
            
            switch championsResult {
            case let .success(champions):
                self.loader.alpha = 0
                print("\(champions.count) champions loaded!")
                self.champions = champions
            case let .failure(error):
                self.loader.startAnimating()
                print(error)
                self.champions.removeAll()
                
                print("No internet connection")
                self.loader.stopAnimating()
                
                DispatchQueue.main.async(execute: {
                    let alertController = UIAlertController(title: "No Internet Connection!", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){(result:UIAlertAction) -> Void in
                        return
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                   
                })

                
                
            }
            self.collectionView.reloadData()
        }
        
        
    }
    
    // MARK: - ConfigUI
    
    func configUI() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont(name: "BradleyHandITCTT-Bold", size: 30)!]
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStory" {
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                let champion = self.champions[selectedIndexPath.row]
                
                let destinationVC = segue.destination as! ChampionDetailViewController
                destinationVC.champion = champion
                destinationVC.storage = store
            }
        }
    }
}

// MARK: - UICollectionView

extension ChampionsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return champions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "ChampionCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ChampionCollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let champion = self.champions[indexPath.row]
        
        // Download the image data
        store.getChampionImage(for: champion) { (result) -> Void in
            
            guard let championIndex = self.champions.index(of: champion),
                case let .success(image) = result
                else {return}
            
            let championIndexPath = IndexPath(item: championIndex, section: 0)
            
            if let cell = self.collectionView.cellForItem(at: championIndexPath) as? ChampionCollectionViewCell {
                cell.updateUI(with: image)
            }
        }
    }
    
    
}
