//
//  CityCollectionTableViewCell.swift
//  Weather
//
//  Created by wangchi on 2017/5/24.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import UIKit

class CityCollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var cityNameLable: UILabel!

    var localCity: SearchResult?
    
    func configureWithLocalCity(_ localCity: SearchResult) {
        if let cityName = localCity.cityName {
            cityNameLable.text = cityName
            cityNameLable.textColor = UIColor.white
        }
    }
    
    func configureWithAddNewCity(_ addNewCity: String) {
         cityNameLable.text = addNewCity
         cityNameLable.textColor = UIColor.white
    }
    
    
}
