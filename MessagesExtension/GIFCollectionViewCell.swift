//
//  GIFCollectionViewCell.swift
//  Giphy
//
//  Created by Stephen Radford on 16/06/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import Messages

class GIFCollectionViewCell: UICollectionViewCell {
    
    private let queue = OperationQueue()
    
    @IBOutlet weak var stickerView: MSStickerView!
    
    var representedGIF: GIF?
    
}
