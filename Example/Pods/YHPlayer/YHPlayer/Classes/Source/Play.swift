//
//  Play.swift
//  YHPlayer
//
//  Created by XiaoBai on 2022/2/16.
//
import Foundation

public protocol Play {
    
    func play()
    func replay()
    func pause()
    func resume()
    func toggleMute()
    func seek(to specificedTime: TimeInterval)
}
public extension Play {
    
    func play() {}
    func replay() {}
    func pause() {}
    func resume() {}
    func toggleMute() {}
    func seek(to specificedTime: TimeInterval) {}
}
