//
//  WeatherCurrentDataView.swift
//  Weather
//
//  Created by wangchi on 2017/4/3.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import UIKit

class WeatherCurrentDataView: UIView {

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLable: UILabel!
    @IBOutlet weak var humidityLable: UILabel!
    @IBOutlet weak var sunriseLable: UILabel!
    @IBOutlet weak var sunsetLable: UILabel!
    @IBOutlet weak var windLable: UILabel!
    @IBOutlet weak var cityNameLable: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var winddegLable: UILabel!
    
    func unixTimeConvertion(_ unixTime: Double) -> String {
        let time = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: cityNameLable.text!)
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: time)
    }
    
    func convertDegreesNorthToCardinalDirection(degrees: Int) -> String {
        let cardinals: [String] = [ "N",
                                    "NE",
                                    "E",
                                    "SE",
                                    "S",
                                    "SW",
                                    "W",
                                    "NW",
                                    "N" ]
        
        let index = Int(round(Double(degrees).truncatingRemainder(dividingBy: 360) / 45))
        
        return cardinals[index]
        
    }    

    var result: SearchResult? {
        didSet {
            guard let result = result else {
                return
            }
            
            if let cityName = result.cityName {
                cityNameLable.text = cityName
            }
            if let temp = result.temp {
                tempLabel.text = String(temp)
            }
            if let weatherDescription = result.description {
                weatherDescriptionLable.text = weatherDescription
            }
            if let humidity = result.humidity {
                humidityLable.text = String(humidity) + "%"
            }
            if let wind = result.wind {
                windLable.text = String(wind) + "m/s"
            }
            if let winddeg = result.winddeg {
                winddegLable.text = convertDegreesNorthToCardinalDirection(degrees: winddeg)
            }
            if let sunrise = result.sunrise {
                sunriseLable.text = "sunrise: " + self.unixTimeConvertion(sunrise)
            }
            if let sunset = result.sunset {
                sunsetLable.text = "sunset: " + self.unixTimeConvertion(sunset)
            }
            if let icon = result.icon, let url = URL(string: "http://openweathermap.org/img/w/\(icon).png") {
                weatherImageView.kf.setImage(with: url)
            }
        }
    }
}
