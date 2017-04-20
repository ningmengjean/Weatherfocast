//
//  ForecastDaysTableViewCell.swift
//  Weather
//
//  Created by wangchi on 2017/4/20.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import UIKit

class ForecastDaysTableViewCell: UITableViewCell {

    @IBOutlet weak var forecastDaysTime: UILabel!
    @IBOutlet weak var forecastDaysTemp: UILabel!
    @IBOutlet weak var forecastDaysImageView: UIImageView!
    
    func configureForecastDaysCell(_ forecastDaysResult: ForecastDays) {
        if let date = forecastDaysResult.dt {
            forecastDaysTime.text = date
        }
        if let tempmax = forecastDaysResult.tempmax, let tempmin = forecastDaysResult.tempmin {
            forecastDaysTemp.text = String(tempmin) + " ~ " + String(tempmax)
        }
        if let icon = forecastDaysResult.icon, let url = URL(string: "http://openweathermap.org/img/w/\(icon).png") {
            forecastDaysImageView.kf.setImage(with: url)
        }
    }
}
