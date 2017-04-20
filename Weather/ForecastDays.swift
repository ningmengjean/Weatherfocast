//
//  ForecastDays.swift
//  Weather
//
//  Created by wangchi on 2017/4/20.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import Foundation

import CoreLocation

import SwiftyJSON

import LatLongToTimezone

class ForecastDays: AnyObject {
    var dt: String?
    var tempmax: Int?
    var tempmin: Int?
    var icon: String?
    var location: CLLocationCoordinate2D?
    
    func unixTimeConvertion(_ unixTime: Double) -> String {
        let time = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        if let location = location,  let timeZone = TimezoneMapper.latLngToTimezone(location) {
            dateFormatter.timeZone = timeZone
            print(timeZone.identifier)
        }
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: time)
    }
    
    func getDayOfWeek(_ today:String) -> String? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        switch weekDay {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return nil
        }
    }
    
    
    init(json: JSON){
        if let date = json["dt"].double {
            dt = getDayOfWeek(unixTimeConvertion(date))
        }
        icon = json["weather"][0]["icon"].string
        tempmax = json["temp"]["max"].int
        tempmin = json["temp"]["min"].int
        
    }
}

