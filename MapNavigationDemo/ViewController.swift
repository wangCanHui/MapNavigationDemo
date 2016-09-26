//
//  ViewController.swift
//  MapNavigationDemo
//
//  Created by 王灿辉 on 16/9/17.
//  Copyright © 2016年 王灿辉. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    /// 导航工具类
    fileprivate var navTool : CHNavigationTool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navTool = CHNavigationTool(currentLocation: CLLocation(latitude: 29.56646671,longitude: 106.47713852), toLocation: CLLocation(latitude: 29.697116999999999,longitude: 106.61015999999999), viewController: self, title: "请选择地图");
        
    }

    @IBAction func showNavView() {
        navTool.showNavigationView()
    }
    
}

