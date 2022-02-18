//
//  YHPlayerLayerView.swift
//  XiaoBaiPlayer
//
//  Created by XiaoBai on 2022/2/8.
//

import UIKit
import AVFoundation
open class YHPlayerLayerView: UIView {
    deinit {
        print("88-YHPlayerLayerView")
    }
    public var player: AVPlayer? {
        get { playerLayer.player }
        set {
            playerLayer.player = newValue
            playerLayer.videoGravity = .resizeAspectFill
        }
    }
    
    public var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    open override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
