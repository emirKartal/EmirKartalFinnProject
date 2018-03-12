//
//  AdModel.swift
//  FinnProject
//
//  Created by Emir Kartal on 27.02.2018.
//  Copyright © 2018 Emir Kartal. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AdvertModel {
    
    struct Advert {
        
        var adIdArray = [String]()
        var adLocationArray = [String]()
        var adDescriptionArray = [String]()
        var adImageURLArray = [String]()
        var adPriceArray = [Int]()
        var adIsFavouriteArray = [Bool]()
        
    }
    
    var advertArrays = Advert()
    
    func getApiData() { // Getting data from remote JSON URL
        
        let url = "https://gist.githubusercontent.com/3lvis/3799feea005ed49942dcb56386ecec2b/raw/63249144485884d279d55f4f3907e37098f55c74/discover.json"
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                let items = json["items"]
                
                for index in 0..<items.count{
                    
                    if  let tempLocation = items[index]["location"].string {
                        self.advertArrays.adLocationArray.append(tempLocation)
                    } else {
                        self.advertArrays.adLocationArray.append("")
                    }
                    if  let tempDescription = items[index]["description"].string {
                        self.advertArrays.adDescriptionArray.append(tempDescription)
                    } else {
                        self.advertArrays.adDescriptionArray.append("")
                    }
                    if  let tempPrice = items[index]["price"]["value"].int {
                        self.advertArrays.adPriceArray.append(tempPrice)
                    } else {
                        self.advertArrays.adPriceArray.append(0)
                    }
                    if  let tempImageURL = items[index]["image"]["url"].string {
                        self.advertArrays.adImageURLArray.append(tempImageURL)
                    } else {
                        self.advertArrays.adImageURLArray.append("")
                    }
                    
                    let tempId = items[index]["id"].string
                    self.advertArrays.adIdArray.append(tempId!) // I assumed that id cannot be nil from the backend
                    self.advertArrays.adIsFavouriteArray.append(false)
                    
                }
                
            case .failure(let error):
                print(error)
            }
        }
        sleep(3)
    }
}

