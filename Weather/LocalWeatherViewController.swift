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

import Moya

fileprivate extension String {
    fileprivate func urlEncode() -> String {
        guard let encode = self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return "" }
        return encode
    }
}

class LocalWeatherViewController: UIViewController, LocationServiceDelegate {
    
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
        let view = forecastData.viewWithTag(100)
        view?.layer.borderWidth = 1
        view?.layer.borderColor = UIColor.white.cgColor
        
        forecastDays.register(UINib(nibName: "ForecastDaysTableViewCell", bundle: nil), forCellReuseIdentifier: "ForecastDaysCell")
        forecastDays.rowHeight = UITableViewAutomaticDimension
        forecastDays.estimatedRowHeight = 100.0
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
    let provider = MoyaProvider<NetworkService>(plugins: [NetworkLoggerPlugin()])
    
    func getCurrentWeatherDataWithLocation(_ location: CLLocation) {
        favHeart.isHidden = true
        spinner.startAnimating()
        provider.request(.currentWeatherByLocation(location: location)) { (result) in
            self.spinner.stopAnimating()
            self.favHeart.isHidden = false
            switch result {
            case .failure(_):
                DispatchQueue.main.async {
                    self.showNetworkError()
                }
            case .success(let moyaResponse):
                let json = self.parseJSON(moyaResponse.data)
                self.locationResult = SearchResult(json: json)
                DispatchQueue.main.async {
                    self.weatherCurrentData.result = self.locationResult
                    if let cityName = self.locationResult?.cityName {
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
        }
    }
    
    func getForecastWeatherDataWithLocation(_ location: CLLocation) {
        provider.request(.forecastHourlyWeatherByLocation(location: location)) { (result) in
            switch result {
            case .failure(_):
                DispatchQueue.main.async {
                    self.showNetworkError()
                }
            case .success(let moyaResponse):
                DispatchQueue.main.async {
                    self.forecastResult = self.parseJSON(moyaResponse.data)["list"].arrayValue.map { Forecast(json: $0)}
                }
            }
            
        }
    }
    
    func getForecastDaysWeatherDataWithLocaiton(_ location: CLLocation) {
        provider.request(.forecastDailyWeatherByLocation(location: location)) { (result) in
            switch result {
            case .failure(_):
                DispatchQueue.main.async {
                    self.showNetworkError()
                }
            case .success(let moyaResponse):
                DispatchQueue.main.async {
                    self.forecastDaysResult = Array (self.parseJSON(moyaResponse.data)["list"].arrayValue.map { ForecastDays(json: $0) }.dropFirst())
                }
            }
        }
    }
    func getCurrentWeatherDataWithCityName(_ cityName: String) {
        favHeart.isHidden = true
        spinner.startAnimating()
        provider.request(.currentWeatherByCity(cityName: cityName)) {(result) in
            self.spinner.stopAnimating()
            self.favHeart.isHidden = false
            switch result {
            case .failure(_):
                DispatchQueue.main.async {
                    self.showNetworkError()
                }
            case .success(let moyaResponse):
                let json = self.parseJSON(moyaResponse.data)
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
        }
    }
    
    func getForecastDataWithCityName(_ cityName: String) {
        provider.request(.forecastHourlyWeatherByCity(cityName: cityName)) { (result) in
            switch result {
            case .failure(_):
                DispatchQueue.main.async {
                    self.showNetworkError()
                }
            case .success(let moyaResponse):
                DispatchQueue.main.async {
                    self.forecastResult = self.parseJSON(moyaResponse.data)["list"].arrayValue.map { Forecast(json: $0)}
                }
            }
            
        }
    }
    
    func getForecastDaysWeatherDataWithCityName(_ cityName: String) {
        provider.request(.forecastDailyWeatherByCity(cityName: cityName)) { (result) in
            switch result {
            case .failure(_):
                DispatchQueue.main.async {
                    self.showNetworkError()
                }
                
            case .success(let moyaResponse):
                DispatchQueue.main.async {
                    self.forecastDaysResult = Array (self.parseJSON(moyaResponse.data)["list"].arrayValue.map { ForecastDays(json: $0) }.dropFirst())
                }
            }
            
        }
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















