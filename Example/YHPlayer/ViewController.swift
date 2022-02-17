//
//  ViewController.swift
//  YHPlayer
//
//  Created by YEHAN on 02/17/2022.
//  Copyright (c) 2022 YEHAN. All rights reserved.
//

import UIKit
import YHPlayer

let RATIO_WIDHT750  = UIScreen.main.bounds.width / 375.0
class ViewController: UIViewController {
    
    /// 远程URL
    let videoURL1 = "http://vfx.mtime.cn/Video/2019/03/18/mp4/190318214226685784.mp4"

    /// 本地URL
    let videoURL2 = Bundle.main.url(forResource: "ElephantSeals.mov", withExtension: nil)!.absoluteString

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(playView)
        layoutAllSubViews()
        
        playView.addCustomeControl(controlView)
        
        let itemConfig = YHPlayerItemConfig(videoURL: videoURL1, isMuted: false, isAutoPlay: false, thumbImg: .init(named: "thumbimg"))
        
        controlView.muteBtn.isSelected = !itemConfig.isMuted
        controlView.playBtn.isSelected = !itemConfig.isAutoPlay
        
        playView.config(with: itemConfig)
        
    }
    
    private func layoutAllSubViews() {
        playView.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.size.equalTo(CGSize(width: KScreenWidth, height: 300*RATIO_WIDHT750))
        }
    }
    private lazy var controlView: YHPlayerControlView = {
        let controlView = YHPlayerControlView(frame: .zero)
        controlView.delegate = self
        return controlView
    }()
    private lazy var playView: YHPlayer = {
        let playView = YHPlayer(frame: .zero)
        playView.delegate = self
        playView.backgroundColor = .black
        return playView
    }()
}


//MARK: ViewController
extension ViewController: YHPlayerDelegate {
    func yhPlayerReadyToPlay(_ player: YHPlayer) {
        print("yhPlayerReadyToPlay")
        controlView.updateProgress(with: 0, duration: player.duration)
    }
    func yhPlayer(_ player: YHPlayer, notifyCurrentProgress progress: TimeInterval) {
        print("progress = \(progress),total = \(player.duration)")
        controlView.updateProgress(with: progress, duration: player.duration)
    }
    func yhPlayer(_ player: YHPlayer, notifyBufferProgress progress: TimeInterval) {
        let scale = (progress / player.duration) * 100
        print("视频总时长：\(player.duration)，已缓冲时长：\(progress)，缓冲进度：\(String(format: "%.2f", scale))%")
    }
    func yhPlayerDidEndPlaying(_ player: YHPlayer) {
        print("yhPlayerDidEndPlaying")
//        player.replay()
    }
}


//MARK: - YHPlayerControlViewDelegate
extension ViewController: YHPlayerControlViewDelegate {
    func yhControlView(_ controlView: YHPlayerControlView, sliderTouchDown slider: UISlider) {
        print("sliderTouchDown")
        playView.pause()
    }
    func yhControlView(_ controlView: YHPlayerControlView, sliderValueChanged slider: UISlider) {
        print("sliderValueChanged-currentValue = \(slider.value)")
        playView.seek(to: TimeInterval(slider.value))
        playView.play()
        
    }
    func yhControlView(_ controlView: YHPlayerControlView, didClickfullScreenBtn fullScreenBtn: UIButton) {
        print("didClickfullScreenBtn")
            playView.fullScreen(fullScreenBtn.isSelected, rotationTo: fullScreenBtn.isSelected ? .landscapeRight : .portrait)
    }
    func yhControlView(_ controlView: YHPlayerControlView, didClickPlayBtn: UIButton) {
        switch playView.playerStatus {
        case .playing: playView.pause()
        case .paused: playView.play()
        default: break
        }
    }
    func yhControlView(_ controlView: YHPlayerControlView, didClickMutedBtn: UIButton) {
        playView.toggleMute()
    }
}





