//
//  DefineMacro.swift
//  XiaoBaiPlayer
//
//  Created by XiaoBai on 2022/2/8.
//

import UIKit

/// get main window
public func getKeyWindow() -> UIWindow? {
    if #available(iOS 13, *) {
        return UIApplication.shared.windows.filter({$0.isKeyWindow}).first ?? nil
    }else {
        return UIApplication.shared.keyWindow ?? nil
    }
}
