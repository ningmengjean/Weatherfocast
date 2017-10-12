//
//  Forecast.swift
//  Weather
//
//  Created by wangchi on 2017/4/15.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import Foundation

import SwiftyJSON

class Forecast {
    
    init(json: JSON) {
        icon = json["weather", 0 , "icon"].string
        temp = json["main", "temp"].int
        dt_txt = generateTimeString(json["dt_txt"].stringValue)
    }
    
    var icon: String?
    var temp: Int?
    var dt_txt: String?
    
    func generateTimeString(_ input: String) -> String?{
        let arr = input.components(separatedBy: " ")
        if let time = arr.last {
            let timearr = time.components(separatedBy: ":")
            return timearr[0] + ":" + timearr[1]
        } else {
            return nil
        }
    }
}
