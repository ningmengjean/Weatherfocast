//
//  ForecastDataViewModel.swift
//  Weather
//
//  Created by wangchi on 2017/7/26.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import Foundation

struct ForecastViewModel {
    let icon: Observable<String>
    let temp: Observable<Int>
    let dt_txt: Observable<String>
    init(_ forecast: Forecast) {
        icon = Observable(forecast.icon)
        temp = Observable(forecast.temp)
        dt_txt = Observable(forecast.dt_txt)
    }
}
