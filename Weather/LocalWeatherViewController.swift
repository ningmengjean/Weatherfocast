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
    
    func forecastDaysWithLonAndLat(_ lon: Double, lat: Double) -> URL {
        let forecastDaysUrlString = String(format: "http://api.openweathermap.org/data/2.5/forecast/daily?lat=%@&lon=%@&cnt=7&units=metric&appid=42fa1d43af611380ae540646f4a2c783", String(lat), String(lon))
        let forecastDaysUrl = URL(string: forecastDaysUrlString)
        return forecastDaysUrl!
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
    
    @IBOutlet weak var forecastDays: UITableView! {
        didSet {
            forecastDays.delegate = self
            forecastDays.dataSource = self
        }
    }
    
    var forecastResult = [Forecast]() {
        didSet {
            forecastData.reloadData()
        }
    }
    
    var forecastDaysResult = [ForecastDays]() {
        didSet {
            forecastDays.reloadData()
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
        forecastData.register(UINib(nibName: "ForecastDataCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ForecastDataCell")
        forecastDays.register(UINib(nibName: "ForecastDaysCell", bundle: nil), forCellReuseIdentifier: "ForecastDaysCell")
        forecastDays.rowHeight = UITableViewAutomaticDimension
        forecastDays.estimatedRowHeight = 44.0
    }

    func getLocation(_service: LocationService, location: CLLocation) {
        getCurrentWeatherDataWithLocation(location)
        getForecastWeatherDataWithLocation(location)
        getForecastDaysWeatherDataWithLocaiton(location)
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
                DispatchQueue.main.async {
                    self.forecastResult = self.parseJSON(data!)["list"].arrayValue.map { Forecast(json: $0) }
                }
            }
        })
        dataTask.resume()
    }
    
    func getForecastDaysWeatherDataWithLocaiton(_ location: CLLocation) {
        let lon = location.coordinate.longitude
        let lat = location.coordinate.latitude
        let forecastDaysUrl = forecastDaysWithLonAndLat(lon, lat: lat)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: forecastDaysUrl, completionHandler: {
            data, response, error in
            if let error = error {
                print("Failure! \(error)")
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.forecastDaysResult = self.parseJSON(data!)["list"].arrayValue.map { ForecastDays(json: $0) }
                }
            }
        })
        dataTask.resume()
    }
}

extension LocalWeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecastResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastDataCell", for: indexPath) as! ForecastDataCell
        let forecast = forecastResult[indexPath.item]
        cell.configureForForecastCell(forecast)
        return cell
    }
    
}

extension LocalWeatherViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 90.0, height: 110.0)
    }
}

extension LocalWeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt  indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastDaysCell", for: indexPath) as! ForecastDaysCell
        let forecastDays = forecastDaysResult[indexPath.row]
        cell.configureForForecastDaysCell(forecastDays)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastDaysResult.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}













