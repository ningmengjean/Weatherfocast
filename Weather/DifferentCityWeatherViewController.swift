//
//  DifferentCityWeatherViewController.swift
//  Weather
//
//  Created by wangchi on 2017/6/8.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import UIKit

class DifferentCityWeatherViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    func newViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LocalWeatherViewController") as! LocalWeatherViewController
        return controller
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        
        var cityCollection = [String]()
        let defaults = UserDefaults.standard
        if let savedCityCollection = defaults.stringArray(forKey: "cityName") {
            cityCollection = savedCityCollection
        }
        var controllers = [self.newViewController()]
        (0..<cityCollection.count).forEach { idx in
            let controller = self.newViewController() as! LocalWeatherViewController
            _ = controller.view
            if idx == 0 {
                controller.startLocation()
            } else {
                controller.cityName = cityCollection[idx - 1]
            }
            controllers.append(controller)
        }
        return controllers
        }()
    
}

extension DifferentCityWeatherViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController as! LocalWeatherViewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController as! LocalWeatherViewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
}


