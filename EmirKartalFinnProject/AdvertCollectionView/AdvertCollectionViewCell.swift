//
//  AdvertCollectionViewCell.swift
//  FinnProject
//
//  Created by Emir Kartal on 27.02.2018.
//  Copyright © 2018 Emir Kartal. All rights reserved.
//

import UIKit

class AdvertCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var advertImage: UIImageView!
    @IBOutlet weak var advertPriceLabel: UILabel!
    @IBOutlet weak var advertLocationLabel: UILabel!
    @IBOutlet weak var advertDescriptionLabel: UILabel!
    @IBOutlet weak var advertFavouriteImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        advertImage.layer.cornerRadius = 15.0
        advertImage.layer.masksToBounds = true
        
        advertFavouriteImage.image  = UIImage(named: "notFavourite.png")
        
        advertPriceLabel.layer.masksToBounds = true
        advertPriceLabel.roundedLabel()
        
    }
}
extension UILabel{
    
    func roundedLabel(){
        
        let maskPath = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: [.bottomLeft , .topRight],
                                     cornerRadii: CGSize(width: 8.0, height: 10))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
        
    }
}
    

