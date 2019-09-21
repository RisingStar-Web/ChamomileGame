//
//  LevelCollectionViewCell.swift
//  ChamomileGame
//
//  Created by Денис Марков on 3/4/19.
//  Copyright © 2019 Денис Марков. All rights reserved.
//

import UIKit

class LevelCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(level: Level) {
        if level.open {
            imageView.image = #imageLiteral(resourceName: "play")
        }
    }
    
    override func prepareForReuse() {
        imageView.image = #imageLiteral(resourceName: "lock")
    }

}
