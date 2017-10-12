//
//  SearchResult.swift
//  Weather
//
//  Created by wangchi on 17/3/28.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import Foundation

import SwiftyJSON

class SearchResult {
    
    init(json: JSON) {
        cityName = json["name"].string
        description = json["weather", 0 , "description"].string
        icon = json["weather", 0 , "icon"].string
        temp = json["main", "temp"].int
        temp_max = json["main", "temp_max"].int
        temp_min = json["main", "temp_min"].int
        lat = json["coord", "lat"].float
        lon = json["coord", "lon"].float    
        humidity = json["main", "humidity"].int
        wind = json["wind", "speed"].double
        sunrise = json["sys", "sunrise"].double
        sunset = json [ "sys", "sunset"].double
        winddeg = json["wind", "deg"].int
    }
    
    var cityName: String?
    var description: String?
    var icon: String?
    var temp: Int?
    var temp_max: Int?
    var temp_min: Int?
    var lat: Float?
    var lon: Float?
    var humidity: Int?
    var wind: Double?
    var sunrise: Double?
    var sunset: Double?
    var winddeg: Int?
}























