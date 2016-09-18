//
//  CHNavigationTool.swift
//  carService
//
//  Created by GMobile No.2 on 16/5/25.
//  Copyright © 2016年 王灿辉. All rights reserved.
//

import Foundation
import MapKit

/// 导航工具类
class CHNavigationTool: NSObject,UIActionSheetDelegate {
    private var currentLocation : CLLocation!
    private var toLocation : CLLocation!
    private var view : UIView!
    private var title : String!
	private var isSetupBaiduMap : Bool = false
	private var isSetupGaoDeMap : Bool = false
    /// 创建单例
    static let sharedInstance: CHNavigationTool = CHNavigationTool()
    
    override init() {
        super.init()
    }
    // 构造函数（经纬度是百度地图的）
    init(currentLocation:CLLocation,toLocation:CLLocation,view:UIView,title:String) {
        self.currentLocation = currentLocation
        self.toLocation = toLocation
        self.view = view
        self.title = title
        super.init()
    }
    
    /// 显示导航视图
    func showNavigationView() {
        // 是否已安装百度地图
        isSetupBaiduMap = UIApplication.sharedApplication().canOpenURL(NSURL(string:"baidumap://map/")!) ? true : false
        // 是否已安装高德地图
        isSetupGaoDeMap = UIApplication.sharedApplication().canOpenURL(NSURL(string:"iosamap://")!) ? true : false
        let actionSheet = UIActionSheet(title: title, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil,otherButtonTitles:"使用苹果自带地图导航")
        if (isSetupGaoDeMap){
            actionSheet.addButtonWithTitle("使用高德地图导航")
        }
        if (isSetupBaiduMap){
            actionSheet.addButtonWithTitle("使用百度地图导航")
        }
        actionSheet.showInView(self.view)
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        let toCoordinate = coordinateTransform(toLocation.coordinate)
		
        if (buttonIndex == 1){ // 使用苹果自带地图导航
            // 苹果自身地图导航
            let toItem = MKMapItem(placemark: MKPlacemark(coordinate: toCoordinate, addressDictionary: nil))
            let items = [toItem]
            let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey:"\(true)"]
            MKMapItem.openMapsWithItems(items, launchOptions: options)
            
        }else if (buttonIndex == 2 ){
			if isSetupGaoDeMap {  // 使用高德地图导航
				setupGaoDeMap(toCoordinate)
			}else if isSetupBaiduMap{ // 使用百度地图导航
				setupBaiduMap(toLocation.coordinate)
			}
			
        }else if (buttonIndex == 3){ // 使用百度地图导航
			setupBaiduMap(toLocation.coordinate)
        }
        
    }
	
    // 调用高德地图
	private func setupGaoDeMap(toCoordinate:CLLocationCoordinate2D){
        // 调用地图路径规划的字符串
		var urlStr = "iosamap://path?sourceApplication=MapNavigationDemo&backScheme=cn.wangCanHui.MapNavigationDemo"
		urlStr += "&dlat=" + "\(toCoordinate.latitude)" + "&dlon=" + "\(toCoordinate.longitude)" + "&dev=0&m=3&t=0"
		
		urlStr = urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
		let url = NSURL(string: urlStr)!
		
		// 手机安装有高德地图app
		if (UIApplication.sharedApplication().canOpenURL(url)) {
			UIApplication.sharedApplication().openURL(url)
		}
	}
	// 调用百度地图
	private func setupBaiduMap(toCoordinate:CLLocationCoordinate2D){
        // 调用地图路径规划的字符串
		var urlStr = "baidumap://map/direction?origin=" + "\(currentLocation.coordinate.latitude)" + ",\(currentLocation.coordinate.longitude)"
		urlStr += "&destination=" + "\(toCoordinate.latitude)" + ",\(toCoordinate.longitude)" + "&mode=driving"
		let url = NSURL(string: urlStr)!
		
		// 手机安装有百度地图app
		if (UIApplication.sharedApplication().canOpenURL(url)) {
			UIApplication.sharedApplication().openURL(url)
		}
	}
	/// 百度地图经纬度转高德、苹果
    func coordinateTransform(coordinate:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
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