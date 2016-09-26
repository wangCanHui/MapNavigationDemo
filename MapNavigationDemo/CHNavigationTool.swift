//
//  CHNavigationTool.swift
//  carService
//
//  Created by GMobile No.2 on 16/5/25.
//  Copyright © 2016年 王灿辉. All rights reserved.
//

import UIKit
import MapKit

/// 导航工具类
class CHNavigationTool: NSObject,UIActionSheetDelegate {
    fileprivate var currentLocation : CLLocation!
    fileprivate var toLocation : CLLocation!
    fileprivate var viewController : UIViewController!
    fileprivate var title : String!
	fileprivate var isSetupBaiduMap : Bool = false
	fileprivate var isSetupGaoDeMap : Bool = false
    /// 创建单例
    static let sharedInstance: CHNavigationTool = CHNavigationTool()
    
    override init() {
        super.init()
    }
    
    /**
     构造函数
     currentLocation : 当前位置 （百度地图经纬度）
     toLocation : 目的地 （百度地图经纬度）
     viewController : 显示到的控制器
     title : 弹出窗口的标题
     */
    init(currentLocation:CLLocation,toLocation:CLLocation,viewController:UIViewController,title:String) {
        self.currentLocation = currentLocation
        self.toLocation = toLocation
        self.viewController = viewController
        self.title = title
        super.init()
    }
    
    /// 显示导航视图
    func showNavigationView() {
        // 是否已安装百度地图
        isSetupBaiduMap = UIApplication.shared.canOpenURL(URL(string:"baidumap://map/")!) ? true : false
        // 是否已安装高德地图
        isSetupGaoDeMap = UIApplication.shared.canOpenURL(URL(string:"iosamap://")!) ? true : false
        
        var alertVC : UIAlertController!
        if UIDevice.current.model != "iPhone" {
            alertVC = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        }else{
            alertVC = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        }
        
        let toCoordinate = coordinateTransform(toLocation.coordinate)
        
        alertVC.addAction(UIAlertAction(title: "使用苹果自带地图导航", style: UIAlertActionStyle.default) { (_) in
            // 苹果自身地图导航
            let toItem = MKMapItem(placemark: MKPlacemark(coordinate: toCoordinate, addressDictionary: nil))
            let items = [toItem]
            let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey:"\(true)"]
            MKMapItem.openMaps(with: items, launchOptions: options)
        })
        
        if isSetupGaoDeMap {
            alertVC.addAction(UIAlertAction(title: "使用高德地图导航", style: UIAlertActionStyle.default) { (_) in
                // 高德地图导航
                self.setupGaoDeMap(toCoordinate)
            })
            
        }
        
        if isSetupBaiduMap {
            alertVC.addAction(UIAlertAction(title: "使用百度地图导航", style: UIAlertActionStyle.default) { (_) in
                // 百度地图导航
                self.setupBaiduMap(self.toLocation.coordinate)
            })
        }
        alertVC.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel) { (_) in
            self.viewController.dismiss(animated: true, completion: nil)
        })
        self.viewController.present(alertVC, animated: true, completion: nil)

    }
    
    // 调用高德地图
	fileprivate func setupGaoDeMap(_ toCoordinate:CLLocationCoordinate2D){
        // 调用地图路径规划的字符串
		var urlStr = "iosamap://path?sourceApplication=MapNavigationDemo&backScheme=cn.wangCanHui.MapNavigationDemo"
		urlStr += "&dlat=" + "\(toCoordinate.latitude)" + "&dlon=" + "\(toCoordinate.longitude)" + "&dev=0&m=3&t=0"
		
		urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
		let url = URL(string: urlStr)!
		
		// 手机安装有高德地图app
		if (UIApplication.shared.canOpenURL(url)) {
			UIApplication.shared.openURL(url)
		}
	}
	// 调用百度地图
	fileprivate func setupBaiduMap(_ toCoordinate:CLLocationCoordinate2D){
        // 调用地图路径规划的字符串
		var urlStr = "baidumap://map/direction?origin=" + "\(currentLocation.coordinate.latitude)" + ",\(currentLocation.coordinate.longitude)"
		urlStr += "&destination=" + "\(toCoordinate.latitude)" + ",\(toCoordinate.longitude)" + "&mode=driving"
		let url = URL(string: urlStr)!
		
		// 手机安装有百度地图app
		if (UIApplication.shared.canOpenURL(url)) {
			UIApplication.shared.openURL(url)
		}
	}
	/// 百度地图经纬度转高德、苹果
    func coordinateTransform(_ coordinate:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        // 国测局GCJ-02坐标体系（谷歌、高德、腾讯），百度坐标BD-09体系
        // 将 BD-09 坐标转换成 GCJ-02  坐标
        let x_pi = 3.14159265358979324 * 3000.0 / 180.0
        let x = coordinate.longitude - 0.0065
        let y = coordinate.latitude - 0.006
        let z = sqrt(x*x + y*y) - 0.00002*sin(y * x_pi)
        let theta = atan2(y,x) - 0.000003*cos(x * x_pi)
        let gg_lat = z*sin(theta)
        let gg_lon = z*cos(theta)
        return CLLocationCoordinate2DMake(gg_lat, gg_lon)
    }
    
}
