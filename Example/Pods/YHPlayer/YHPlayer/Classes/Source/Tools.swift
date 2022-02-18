//
//  DefineMacro.swift
//  XiaoBaiPlayer
//
//  Created by XiaoBai on 2022/2/8.
//

import UIKit

//frame
let KScreenSize   = UIScreen.main.bounds
let KScreenWidth  = KScreenSize.size.width
let KScreenHeight = KScreenSize.size.height

////屏幕适配计算,用于Masonry布局页面，%百分比适配布局比例计算
let RATIO_WIDHT750  = KScreenWidth / 375.0


/// get main window
func getKeyWindow() -> UIWindow? {
    if #available(iOS 13, *) {
        return UIApplication.shared.windows.filter({$0.isKeyWindow}).first ?? nil
    }else {
        return UIApplication.shared.keyWindow ?? nil
    }
}
