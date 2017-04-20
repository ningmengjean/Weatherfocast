//
//  ForecastDataCellCollectionViewCell.swift
//  Weather
//
//  Created by wangchi on 2017/4/18.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import UIKit

class ForecastDataCell: UICollectionViewCell {
    
    @IBOutlet weak var forecastTime: UILabel!
    @IBOutlet weak var forecastTemp: UILabel!
    @IBOutlet weak var forecastImageView: UIImageView!
    
    let tempEmoji = "℃"
    
    func configureForForecastCell(_ forecastResult: Forecast)  {
        
        if let temp = forecastResult.temp {
            forecastTemp.text = String(temp) + String(tempEmoji)
        }
        if let time = forecastResult.dt_txt {
            forecastTime.text = time
        }
        if let icon = forecastResult.icon, let url = URL(string: "http://openweathermap.org/img/w/\(icon).png") {
            forecastImageView.kf.setImage(with: url)
        }
    }
}
