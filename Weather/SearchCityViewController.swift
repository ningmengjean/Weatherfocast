//
//  SearchCityViewController.swift
//  Weather
//
//  Created by wangchi on 2017/5/17.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import UIKit

protocol SearchCityViewControllerDelegate: class {
    func shouldSearchText(_ text: String)
}



class SearchCityViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar! 
 
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.register(UINib(nibName: "NothingFoundCell", bundle: nil), forCellReuseIdentifier: "NothingFoundCell")
    }
    
    weak var delegate: SearchCityViewControllerDelegate?
}

extension SearchCityViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            let alert = UIAlertController(
                title: "Whoops...",
                message:
                "There was no cityname here. Please give it to me,thanks.",
                preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {
            let text = searchBar.text
            delegate?.shouldSearchText(text!)
        }
    }
}

extension SearchCityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension SearchCityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}








