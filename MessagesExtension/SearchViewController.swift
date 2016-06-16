//
//  SearchViewController.swift
//  Giphy
//
//  Created by Stephen Radford on 16/06/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import Messages

class SearchViewController: MSMessagesAppViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var gifs = [GIF]()
    
    
    // MARK: - Search
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text else {
            return
        }
        
        Giphy.search(query: text) { gifs in
            print(gifs)
            self.gifs = gifs
            self.collectionView.reloadData()
        }
    }
    
    
    // MARK: - UICollectionView
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GIF Cell", for: indexPath) as? GIFCollectionViewCell else { fatalError("Unable to dequeue am GIFCollectionViewCell") }
        
        let gif = gifs[indexPath.row]
        
        cell.representedGIF = gif
        
        // Use a placeholder sticker while we fetch the real one from the cache.
        let cache = GIFCache.cache
        cell.stickerView.sticker = cache.placeholderSticker
        
        // Fetch the sticker for the ice cream from the cache.
        cache.sticker(for: gif) { sticker in
            OperationQueue.main().addOperation {
                // If the cell is still showing the same ice cream, update its sticker view.
                guard cell.representedGIF!.id == gif.id else { return }
                cell.stickerView.sticker = sticker
            }
        }
        
        return cell

        
    }

}
