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
    
    enum AcceptType {
        case cityName(String)
        case cityLocation(CLLocationCoordinate2D)
    }
    
    var acceptType: AcceptType = .cityName("")
    
    
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
    
    func urlWithCityName(_ cityName: String) -> URL {
        let urlString = String(format: "http://api.openweathermap.org/data/2.5/weather?q=%@&units=metric&appid=42fa1d43af611380ae540646f4a2c783", cityName.urlEncode())
        let url = URL(string: urlString)
        return url!
    }
    
    func forecastWithCityName(_ cityName: String) -> URL {
        let forecastUrlString = String(format: "http://api.openweathermap.org/data/2.5/forecast?q=%@&units=metric&appid=42fa1d43af611380ae540646f4a2c783", cityName.urlEncode())
        let forecastUrl = URL(string: forecastUrlString)
        return forecastUrl!
    }
    
    func forecastDaysWithCityName(_ cityName: String) -> URL {
        let forecastDaysUrlString = String(format: "http://api.openweathermap.org/data/2.5/forecast/daily?q=%@&cnt=7&units=metric&appid=42fa1d43af611380ae540646f4a2c783", cityName.urlEncode())
        let forecastDaysUrl = URL(string: forecastDaysUrlString)
        return forecastDaysUrl!
    }
    @IBOutlet weak var favHeart: UIButton!
    
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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBAction func addFav(_ sender: UIButton) {
        guard let cityName = weatherCurrentData.cityNameLable.text else {
            return
        }
        if sender.image(for: .normal) == UIImage(named: "unstar") {
            sender.setImage(UIImage(named: "star"), for: .normal)
            if var arr = UserDefaults.standard.array(forKey: "cityName") as? [String] {
                if !arr.contains(cityName) {
                    arr.append(cityName)
                    UserDefaults.standard.set(arr, forKey: "cityName")
                }
            } else {
                UserDefaults.standard.set([cityName], forKey: "cityName")
            }
        } else if sender.image(for: .normal) == UIImage(named: "star") {
            sender.setImage(UIImage(named:"unstar"), for: .normal)
            if var arr = UserDefaults.standard.array(forKey: "cityName") as? [String] {
                if let indx = arr.index(of: cityName) {
                    arr.remove(at: indx)
                    UserDefaults.standard.set(arr, forKey: "cityName")
                }
            }
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
        forecastDays.register(UINib(nibName: "ForecastDaysTableViewCell", bundle: nil), forCellReuseIdentifier: "ForecastDaysCell")
        forecastDays.rowHeight = UITableViewAutomaticDimension
        forecastDays.estimatedRowHeight = 100.0
    }
    
    var cityName: String? {
        didSet {
            guard let cityName = cityName else {
                return
            }
            getCurrentWeatherDataWithCityName(cityName)
            getForecastDataWithCityName(cityName)
            getForecastDaysWeatherDataWithCityName(cityName)
        }
    }
    
    func startLocation() {
        locationService.requestLocation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Search" {
            let controller = segue.destination as! SearchCityViewController
            controller.delegate = self
        } else if segue.identifier == "Favorite List" {
            let controller = segue.destination as! CityCollectionViewController
            controller.delegate = self
            controller.result = result
            controller.locationResult = locationResult
        }
    }

    func getLocation(_service: LocationService, location: CLLocation) {
        getCurrentWeatherDataWithLocation(location)
        getForecastWeatherDataWithLocation(location)
        getForecastDaysWeatherDataWithLocaiton(location)
    }
    
    func showNetworkError() {
        let alert = UIAlertController(
            title: "Whoops...",
            message:
            "There was an error with your networking. Please try again.",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    var result: SearchResult?
    var locationResult: SearchResult?
    
    func getCurrentWeatherDataWithLocation(_ location: CLLocation) {
        favHeart.isHidden = true
        spinner.startAnimating()
        let lon = location.coordinate.longitude
        let lat = location.coordinate.latitude
        let url = urlWithLonAndLat(lon, lat: lat)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url, completionHandler: {
            data, response, error in
            self.spinner.stopAnimating()
            self.favHeart.isHidden = false
            if let error = error {
                print("Failure! \(error)")
                DispatchQueue.main.async {
                    self.showNetworkError()
                }
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let json = self.parseJSON(data!)
                self.locationResult = SearchResult(json: json)
                DispatchQueue.main.async {
                    self.weatherCurrentData.result = self.locationResult
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
                    self.forecastDaysResult = Array (self.parseJSON(data!)["list"].arrayValue.map { ForecastDays(json: $0) }.dropFirst())
                }
            }
        })
        dataTask.resume()
    }
    
    func getCurrentWeatherDataWithCityName(_ cityName: String) {
        favHeart.isHidden = true
        spinner.startAnimating()
        let url = urlWithCityName(cityName)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url, completionHandler: {
            data, response, error in
            self.favHeart.isHidden = false
            self.spinner.stopAnimating()
            if let error = error {
                print("Failure! \(error)")
                DispatchQueue.main.async {
                    self.showNetworkError()
                }
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let json = self.parseJSON(data!)
                self.result = SearchResult(json: json)
                DispatchQueue.main.async {
                    self.weatherCurrentData.result = self.result
                    if let cityName = self.result?.cityName {
                        if let arr = UserDefaults.standard.array(forKey: "cityName") as? [String] {
                            if arr.contains(cityName) {
                                self.favHeart.setImage(UIImage(named:"star"), for: .normal)
                            } else {
                                self.favHeart.setImage(UIImage(named:"unstar"), for: .normal)
                            }
                        }
                    } else {
                        self.favHeart.setImage(UIImage(named:"unstar"), for: .normal)
                    }
                }
            }
        })
        dataTask.resume()
    }
    
    func getForecastDataWithCityName(_ cityName: String) {
        let url = forecastWithCityName(cityName)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url, completionHandler: {
            data, response, error in
            if let error = error {
                print("Failure! \(error)")
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.forecastResult = self.parseJSON(data!)["list"].arrayValue.map { Forecast(json: $0)}
            }
            }
        })
            dataTask.resume()
    }
    
    func getForecastDaysWeatherDataWithCityName(_ cityName: String) {
        let url = forecastDaysWithCityName(cityName)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url, completionHandler: {
            data, response, error in
            if let error = error {
                print("Failure! \(error)")
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.forecastDaysResult = Array (self.parseJSON(data!)["list"].arrayValue.map { ForecastDays(json: $0) }.dropFirst())
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastDaysCell", for: indexPath) as! ForecastDaysTableViewCell
        let forecastDays = forecastDaysResult[indexPath.row]
        cell.configureForecastDaysCell(forecastDays)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastDaysResult.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension LocalWeatherViewController: SearchCityViewControllerDelegate {
    func shouldSearchText(_ text: String) {
        //把searchcontroller dismiss掉
        dismiss(animated: true, completion: nil)
        getCurrentWeatherDataWithCityName(text)
        getForecastDataWithCityName(text)
        getForecastDaysWeatherDataWithCityName(text)
    }
}

extension LocalWeatherViewController: CityCollectionViewControllerDelegate {
    func sendText(_ text: String) {
        dismiss(animated: true, completion: nil)
        getCurrentWeatherDataWithCityName(text)
        getForecastDataWithCityName(text)
        getForecastDaysWeatherDataWithCityName(text)
    }
}















