//
//  CityCollectionViewController.swift
//  Weather
//
//  Created by wangchi on 2017/5/24.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import UIKit

protocol  CityCollectionViewControllerDelegate: class {
    func sendText(_ text: String)
}

class CityCollectionViewController: UIViewController,UISearchControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "CityCollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CityCollectionCell")
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        let defaults = UserDefaults.standard
        if let savedCityCollection = defaults.stringArray(forKey: "cityName") {
            cityCollection = savedCityCollection
        }
        tableView.reloadData()
    }

    @IBOutlet weak var tableView: UITableView!
    
    var searchText: String?
    var cityCollection = [String]()
    var result: SearchResult?
    var locationResult: SearchResult?
    weak var delegate: CityCollectionViewControllerDelegate?
    
}

extension CityCollectionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
                   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1:
                return cityCollection.count
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCollectionCell", for: indexPath) as!
        CityCollectionTableViewCell
        cell.backgroundColor = UIColor.init(red: 0, green: 161, blue: 222, alpha: 0)
       
        switch indexPath.section {
            case 0 :
                if let localCityCell = locationResult {
                cell.configureWithLocalCity(localCityCell)
            }
            case 1 :
                
                let cityCollectionCell = cityCollection
                cell.configureWithAddNewCity(cityCollectionCell[indexPath.row])
            default: break
        }
         return cell
    }
    
}

extension CityCollectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CityCollectionTableViewCell
        guard let text = cell.cityNameLable.text else {
            return
        }
        delegate?.sendText(text)
    }
}

