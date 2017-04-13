//
//  LocationService.swift
//  Weather
//
//  Created by wangchi on 2017/4/12.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import Foundation

import CoreLocation

protocol LocationServiceDelegate: class {
    func fetchWeatherDateWithLonAndLat(_service: LocationService, location: CLLocation)
}

class LocationService: NSObject {
    weak var delegate: LocationServiceDelegate?
    fileprivate let locationManager = CLLocationManager()
    override init() {
        super .init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func requestLocation()  {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, fetchWeatherDateWithLonAndLat locations: [CLLocation]) {
        let sortedLocations = locations.filter{ $0.horizontalAccuracy > 0 }.sorted { $0.horizontalAccuracy < $1.horizontalAccuracy }
        if let location = sortedLocations.first {
            delegate?.fetchWeatherDateWithLonAndLat(_service: self, location: location)
           
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error finding location: \(error.localizedDescription)")
    }
}
