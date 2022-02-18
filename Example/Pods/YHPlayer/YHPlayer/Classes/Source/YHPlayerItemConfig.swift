//
//  YHPlayItemConfig.swift
//  XiaoBaiPlayer
//
//  Created by XiaoBai on 2022/2/7.
//

import Foundation
import UIKit

public struct YHPlayerItemConfig {
    /// 视频地址
    public var videoURL: String
    
    /// 是否静音
    public var isMuted: Bool
    
    /// 是否自动播放
    public var isAutoPlay: Bool
    
    /// 占位图
    public var thumbImg: UIImage?
    
    /// 占位图URL
    public var thumbImgURL: String?
    
    public init(videoURL: String,
         isMuted: Bool = true,
         isAutoPlay: Bool = true,
         thumbImg: UIImage? = nil,
         thumbImgURL: String? = nil) {
        self.videoURL = videoURL
        self.isMuted = isMuted
        self.isAutoPlay = isAutoPlay
        self.thumbImg = thumbImg
        self.thumbImgURL = thumbImgURL
    }
}
