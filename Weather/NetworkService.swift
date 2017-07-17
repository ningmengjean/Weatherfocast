//
//  NetworkService.swift
//  Weather
//
//  Created by wangchi on 2017/7/12.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import Foundation 
import Moya
import CoreLocation

let appId = "42fa1d43af611380ae540646f4a2c783"

enum NetworkService {
    case currentWeatherByCity(cityName: String)
    case currentWeatherByLocation(location: CLLocation)
    case forecastHourlyWeatherByCity(cityName: String)
    case forecastHourlyWeatherByLocation(location: CLLocation)
    case forecastDailyWeatherByCity(cityName: String)
    case forecastDailyWeatherByLocation(location: CLLocation)
}

extension NetworkService: TargetType {
    var baseURL: URL { return URL(string:"http://api.openweathermap.org/data/2.5")!}
    var path: String {
        switch self {
        case .currentWeatherByCity(cityName: _):
            return "/weather"
        case .currentWeatherByLocation(location: _):
            return "/weather"
        case .forecastHourlyWeatherByCity(cityName: _):
            return "/forecast"
        case .forecastHourlyWeatherByLocation(location: _):
            return "/forecast"
        case .forecastDailyWeatherByCity(cityName: _):
            return "/forecast/daily"
        case .forecastDailyWeatherByLocation(location: _):
            return "/forecast/daily"
        }
    }
    var method: Moya.Method {
        switch self {
        case .currentWeatherByLocation(location: _),
             .currentWeatherByCity(cityName: _),
             .forecastHourlyWeatherByLocation(location: _),
             .forecastHourlyWeatherByCity(cityName: _),
             .forecastDailyWeatherByCity(cityName: _),
             .forecastDailyWeatherByLocation(location: _):
            return .get
        }
    }
    var parameters:[String: Any]? {
        switch self {
        case .currentWeatherByCity(cityName: let name):
            return ["q": name,"units": "metric","appid": appId]
        case .currentWeatherByLocation(location: let l):
            return ["lat": l.coordinate.latitude,"lon": l.coordinate.longitude,"units": "metric","appid": appId]
        case .forecastHourlyWeatherByCity(cityName: let name):
            return ["q": name,"cnt": "15","units": "metric","appid": appId]
        case .forecastHourlyWeatherByLocation(location: let l):
            return ["lat": l.coordinate.latitude,"lon": l.coordinate.longitude,"cnt": "15","units": "metric","appid": appId]
        case .forecastDailyWeatherByCity(cityName: let name):
            return ["q": name,"cnt": "7","units": "metric","appid": appId]
        case .forecastDailyWeatherByLocation(location: let l):
            return ["lat": l.coordinate.latitude,"lon": l.coordinate.longitude,"cnt": "7","units": "metric","appid": appId]
        }
    }
    var parameterEncoding: ParameterEncoding {
        switch self {
           case .currentWeatherByLocation(location: _),
                .currentWeatherByCity(cityName: _),
                .forecastHourlyWeatherByLocation(location: _),
                .forecastHourlyWeatherByCity(cityName: _),
                .forecastDailyWeatherByCity(cityName: _),
                .forecastDailyWeatherByLocation(location: _):
            return URLEncoding.queryString
        }
    }
    var sampleData: Data {
        return Data()
    }
    var task: Task {
        switch self {
        case .currentWeatherByLocation(location: _),
             .currentWeatherByCity(cityName: _),
             .forecastHourlyWeatherByLocation(location: _),
             .forecastHourlyWeatherByCity(cityName: _),
             .forecastDailyWeatherByCity(cityName: _),
             .forecastDailyWeatherByLocation(location: _):
            return .request
        }
    }
    var validate: Bool {
        return false 
    }
}


















