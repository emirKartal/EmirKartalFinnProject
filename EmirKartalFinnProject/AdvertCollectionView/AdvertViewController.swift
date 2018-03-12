//
//  ViewController.swift
//  FinnProject
//
//  Created by Emir Kartal on 27.02.2018.
//  Copyright © 2018 Emir Kartal. All rights reserved.
//

import UIKit

class AdvertViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var advertCollectionView: UICollectionView!
    @IBOutlet weak var favouriteSwitch: UISwitch!
    @IBOutlet weak var favouriteLabel: UILabel!
    
    var adModel = AdvertModel()
    var cache = NSCache<NSString, AnyObject>()
    var favouriteIndex = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         if let array = UserDefaults.standard.object(forKey: "favourite"), let index = UserDefaults.standard.object(forKey: "index") {
         adModel.advertArrays.adIsFavouriteArray = array as! [Bool]
         favouriteIndex = index as! [Int]
         }
        
        customizeCollectionView()
        advertCollectionView.delegate = self
        advertCollectionView.dataSource = self
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.adModel.getApiData()
            DispatchQueue.main.async {
                self.advertCollectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favouriteSwitch.isOn ? favouriteIndex.count : self.adModel.advertArrays.adLocationArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = advertCollectionView.dequeueReusableCell(withReuseIdentifier: "adCell", for: indexPath) as! AdvertCollectionViewCell
        
        // The codding block shows the favourite adverts thanks to the array which is filled in tapEdit function
        if favouriteSwitch.isOn {
            
            let newIndex = favouriteIndex[indexPath.row]
            let imageURLString = "https://images.finncdn.no/dynamic/480x360c/\(self.adModel.advertArrays.adImageURLArray[newIndex])"
            let imageURL = URL(string: imageURLString)
            let data = try! Data(contentsOf: imageURL!)
            
            if let cachedImage = cache.object(forKey: imageURLString as NSString) {
                cell.advertImage.image = cachedImage as? UIImage
            } else {
                cell.advertImage.image = UIImage(data: data)
            }
            
            cell.advertLocationLabel.text = self.adModel.advertArrays.adLocationArray[newIndex]
            cell.advertDescriptionLabel.text = self.adModel.advertArrays.adDescriptionArray[newIndex]
            cell.advertPriceLabel.text = "  \(self.adModel.advertArrays.adPriceArray[indexPath.row]),-"
            cell.advertFavouriteImage.image = UIImage(named: "favourite.png")
            
            return cell
            
        } else { // The coding block shows all adverts in the collection view
            
            cell.advertLocationLabel.text = self.adModel.advertArrays.adLocationArray[indexPath.row]
            cell.advertDescriptionLabel.text = self.adModel.advertArrays.adDescriptionArray[indexPath.row]
            cell.advertPriceLabel.text = "  \(self.adModel.advertArrays.adPriceArray[indexPath.row]),-"
            
            // This if statement prevent changing icon without tapping favourite icon. Before that, if we tap one of favourite icons, some favourite icons in collection can be selected.
            if adModel.advertArrays.adIsFavouriteArray[indexPath.row] {
                cell.advertFavouriteImage.image = UIImage(named: "favourite.png")
            } else {
                cell.advertFavouriteImage.image = UIImage(named: "notFavourite.png")
            }
            
            let imageURLString = "https://images.finncdn.no/dynamic/480x360c/\(self.adModel.advertArrays.adImageURLArray[indexPath.row])"
            let imageURL = URL(string: imageURLString)
            
            if let cachedImage = cache.object(forKey: imageURLString as NSString) {
                cell.advertImage.image = cachedImage as? UIImage
            }else {
                
                DispatchQueue.main.async {
                    do {
                        let data = try Data(contentsOf: imageURL!)
                        cell.advertImage.image = UIImage(data: data)
                        self.cache.setObject(cell.advertImage.image!, forKey: imageURLString as NSString)
                    }catch {
                        cell.advertImage.image = UIImage(named: "imageError.png")
                    }
                }
            }
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapEdit(sender:)))
            cell.advertFavouriteImage.isUserInteractionEnabled = true
            cell.advertFavouriteImage.addGestureRecognizer(recognizer)
            
            return cell
        }
    }
    
    @IBAction func switchOnOff(_ sender: UISwitch) {
        
        if sender.isOn {
            favouriteLabel.text = "Show All"
        } else {
            favouriteLabel.text = "Show Favourites"
        }
        
        DispatchQueue.main.async {
            self.advertCollectionView.reloadData()
        }
    }
    
    @objc func tapEdit(sender: UITapGestureRecognizer){
        // This function is about adding action the favourite icon which is in the each cell. Also it provides, adding the indexpath of the collection view to an array to show them in favourites.
        
        let tapLocation = sender.location(in: self.advertCollectionView)
        if let tapIndexPath = self.advertCollectionView.indexPathForItem(at: tapLocation){
            
            if let tappedCell = self.advertCollectionView.cellForItem(at: tapIndexPath) as? AdvertCollectionViewCell {
                
                if tappedCell.advertFavouriteImage.image == UIImage(named: "notFavourite.png") {
                    
                    adModel.advertArrays.adIsFavouriteArray[tapIndexPath.row] = true
                    favouriteIndex.append(tapIndexPath.row)
                    tappedCell.advertFavouriteImage.image = UIImage(named: "favourite.png")
                    
                } else {
                    
                    if favouriteSwitch.isOn == false {
                        tappedCell.advertFavouriteImage.image = UIImage(named: "notFavourite.png")
                        let removeIndex = favouriteIndex.index(of: tapIndexPath.row)
                        adModel.advertArrays.adIsFavouriteArray[tapIndexPath.row] = false
                        favouriteIndex.remove(at: removeIndex!)
                        
                    }else {
                        tappedCell.advertFavouriteImage.image = UIImage(named: "notFavourite.png")
                        adModel.advertArrays.adIsFavouriteArray[favouriteIndex[tapIndexPath.row]] = false
                        favouriteIndex.remove(at: tapIndexPath.row)
                        self.advertCollectionView.reloadData()
                    }
                }
                UserDefaults.standard.set(adModel.advertArrays.adIsFavouriteArray, forKey: "favourite")
                UserDefaults.standard.set(favouriteIndex, forKey: "index")
            }
        }
    }
    
    func customizeCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        advertCollectionView.collectionViewLayout = layout
        layout.sectionInset = UIEdgeInsetsMake(7, 7, 7, 7)
        let itemWidth = (UIScreen.main.bounds.width-24)/2
        layout.itemSize = CGSize(width: itemWidth , height: itemWidth )
        
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        
    }
}

