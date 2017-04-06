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

fileprivate extension String {
    fileprivate func urlEncode() -> String {
        guard let encode = self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return "" }
        return encode
    }
}

class LocalWeatherViewController: UIViewController {

    func urlWithCityName(_ cityName: String) -> URL {
        let urlString = String(format: "http://api.openweathermap.org/data/2.5/weather?q=%@&units=metric&appid=42fa1d43af611380ae540646f4a2c783", cityName.urlEncode())
        let url = URL(string: urlString)
        return url!
    }
   
    @IBOutlet weak var weatherCurrentData: WeatherCurrentDataView!
  
    func parseJSON(_ data: Data) -> JSON {
        return JSON(data: data)
    }
}

extension LocalWeatherViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let url = urlWithCityName(searchBar.text!)
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
