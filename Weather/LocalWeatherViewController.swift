//
//  ViewController.swift
//  Weather
//
//  Created by wangchi on 17/3/27.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import UIKit

import SwiftyJSON

import Kingfisher

import LatLongToTimezone

import CoreLocation

fileprivate extension String {
    fileprivate func urlEncode() -> String {
        guard let encode = self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return "" }
        return encode
    }
}


class LocalWeatherViewController: UIViewController {
    
    var locationService = LocationService()
    
    
    func urlWithLonAndLat(_ lon: Double, lat: Double) -> URL {
        let urlString = String(format: "http://api.openweathermap.org/data/2.5/weather?lat=%@&lon=%@&units=metric&appid=42fa1d43af611380ae540646f4a2c783")
        
        let url = URL(string: urlString)
        return url!
    }
   
    @IBOutlet weak var weatherCurrentData: WeatherCurrentDataView!
  
    func parseJSON(_ data: Data) -> JSON {
        return JSON(data: data)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchWeatherDateWithLonAndLat(location)
    }
    
    func fetchWeatherDateWithLonAndLat(_ location: CLLocation) {
        let lon = location.coordinate.longitude
        let lat = location.coordinate.latitude
        let url = urlWithLonAndLat(lon, lat: lat)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url, completionHandler: {
            data, response, error in
            if let error = error {
                print("Failure! \(error)")
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let json = self.parseJSON(data!)
                let result = SearchResult(json: json)
                DispatchQueue.main.async {
                    self.weatherCurrentData.result = result
                }
            }
        })
        dataTask.resume()
    }
    
}












