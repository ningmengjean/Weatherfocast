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

class LocalWeatherViewController: UIViewController, LocationServiceDelegate {
    
    func urlWithLonAndLat(_ lon: Double, lat: Double) -> URL {
        let urlString = String(format: "http://api.openweathermap.org/data/2.5/weather?lat=%@&lon=%@&units=metric&appid=42fa1d43af611380ae540646f4a2c783", String(lat), String(lon))
        
        let url = URL(string: urlString)
        return url!
    }
    
    func forecastUrlWithLonAndLat(_ lon: Double, lat: Double) -> URL {
        let forecastUrlString = String(format: "http://api.openweathermap.org/data/2.5/forecast?lat=%@&lon=%@&cnt=40&units=metric&appid=42fa1d43af611380ae540646f4a2c783", String(lat), String(lon))
        let forecastUrl = URL(string: forecastUrlString)
        return forecastUrl!
    }
    
    @IBAction func pressButton(_ sender: Any) {
        locationService.requestLocation()
    }
    
    @IBOutlet weak var weatherCurrentData: WeatherCurrentDataView!
  
    
    @IBOutlet weak var forecastData: UICollectionView! {
        didSet {
            forecastData.delegate = self
            forecastData.dataSource = self
        }
    }
    
    func parseJSON(_ data: Data) -> JSON {
        return JSON(data: data)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    let locationService = LocationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationService.delegate = self
        forecastData.register(UINib(nibName: "ForecastCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ForecastCell")
    }

    func getLocation(_service: LocationService, location: CLLocation) {
        getCurrentWeatherDataWithLocation(location)
        getForecastWeatherDataWithLocation(location)
    }
    
    func getCurrentWeatherDataWithLocation(_ location: CLLocation) {
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
    
    func getForecastWeatherDataWithLocation(_ location: CLLocation) {
        let lon = location.coordinate.longitude
        let lat = location.coordinate.latitude
        let forecastUrl = forecastUrlWithLonAndLat(lon, lat: lat)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: forecastUrl, completionHandler: {
            data, response, error in
            if let error = error {
                print("Failure! \(error)")
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let forecastResults = self.parseJSON(data!)["list"].arrayValue.map { Forecast(json: $0) }
                DispatchQueue.main.async {
                    for i in 0...39 {
                    self.forecastData.cell = forecastResults[i]
                    }
                }
            }
        })
        dataTask.resume()
    }
}

extension LocalWeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCell", for: indexPath) as! ForecastDataCell
        cell.configureForForecastCell(forecast)
        return cell
    }
    
}













