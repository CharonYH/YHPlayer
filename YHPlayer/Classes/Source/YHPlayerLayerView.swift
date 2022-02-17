//
//  YHPlayerLayerView.swift
//  XiaoBaiPlayer
//
//  Created by XiaoBai on 2022/2/8.
//

import UIKit
import AVFoundation
class YHPlayerLayerView: UIView {
    deinit {
        print("88-YHPlayerLayerView")
    }
    var player: AVPlayer? {
        get { playerLayer.player }
        set {
            playerLayer.player = newValue
            playerLayer.videoGravity = .resizeAspectFill
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
