//
//  SearchViewController.swift
//  Giphy
//
//  Created by Stephen Radford on 16/06/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import Messages

class SearchViewController: MSMessagesAppViewController, MSStickerBrowserViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var browserView: MSStickerBrowserView!
    
    var stickers = [MSSticker]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        browserView.dataSource = self
    }
    
    // MARK: - Search
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text else {
            return
        }
        
        Giphy.search(query: text) { stickers in
            self.stickers = stickers
            self.browserView.reloadData()
        }
    }
    
    // MARK: - MSStickerBrowserViewController
    
    func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        return stickers.count
    }
    
    func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        let sticker = stickers[index]
        return sticker
    }
    


}
