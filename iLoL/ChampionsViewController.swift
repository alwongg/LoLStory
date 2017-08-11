//
//  ChampionsViewController.swift
//  iLoL
//
//  Created by Alex Wong on 8/11/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import UIKit

// MARK: - ChampionsViewController

class ChampionsViewController: UIViewController {

    // MARK: - Properties
    
    var champions = [ChampionDetails]()
    var store: ChampionStore!
    
    // MARK: - IBOutlets
    
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        store.fetchChampions {
            (championsResult) -> Void in
            
            switch championsResult {
            case let .success(champions):
                print("Successfully found \(champions.count) champions.")
                self.champions = champions
            case let .failure(error):
                print("Error fetching champions: \(error)")
                self.champions.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto"?:
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                
                let champion = self.champions[selectedIndexPath.row]
                
                let destinationVC = segue.destination as! ChampionDetailViewController
                destinationVC.champion = champion
                destinationVC.store = store
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
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
        store.fetchChampionImage(for: champion) { (result) -> Void in
            
            guard let championIndex = self.champions.index(of: champion),
                case let .success(image) = result else {
                    return
            }
            let championIndexPath = IndexPath(item: championIndex, section: 0)
            
            if let cell = self.collectionView.cellForItem(at: championIndexPath) as? ChampionCollectionViewCell {
                cell.update(with: image)
            }
        }
    }

    
}