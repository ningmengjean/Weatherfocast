//
//  File.swift
//  Weather
//
//  Created by wangchi on 2017/7/25.
//  Copyright © 2017年 Zhu xiaojin. All rights reserved.
//

import Foundation

class Observable<T> {
    typealias Observer = (T) -> Void
    var observer: Observer?
    
    func observe(_ observer: Observer?) {
        self.observer = observer
        observer?(value)
    }
    
    var value: T {
        didSet {
            observer?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
}
