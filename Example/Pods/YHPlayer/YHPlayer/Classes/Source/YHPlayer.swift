//
//  YHPlayer.swift
//  YHPlayer
//
//  Created by XiaoBai on 2022/2/8.
//

import UIKit
import AVFoundation
import SnapKit
private var YHPlayerObserverContext = 0

public protocol YHPlayerDelegate: NSObjectProtocol {
    /// 更新播放进度
    func yhPlayer(_ player: YHPlayer, notifyCurrentProgress progress: TimeInterval)
    
    /// 更新缓冲进度
    func yhPlayer(_ player: YHPlayer, notifyBufferProgress progress: TimeInterval)
    
    /// 准备播放
    func yhPlayerReadyToPlay(_ player: YHPlayer)
    
    /// 失败播放
    func yhPlayerFailedToPlay(_ player: YHPlayer, error: YHPlayer.Error)
    
    /// 播放完毕
    func yhPlayerDidEndPlaying(_ player: YHPlayer)
    
    /// 播放中断（来电话等优先级高的）
    func yhPlayerInterruptioned(_ player: YHPlayer, interruptionType type: YHPlayer.InterruptionType)
    
    /// 状态发生改变
    func yhPlayerStatusChanged(_ player: YHPlayer, status: YHPlayer.PlayStatus)
}
public extension YHPlayerDelegate {
    func yhPlayer(_ player: YHPlayer, notifyCurrentProgress progress: TimeInterval) {}
    func yhPlayer(_ player: YHPlayer, notifyBufferProgress progress: TimeInterval) {}
    func yhPlayerReadyToPlay(_ player: YHPlayer) {}
    func yhPlayerFailedToPlay(_ player: YHPlayer, error: YHPlayer.Error) {}
    func yhPlayerDidEndPlaying(_ player: YHPlayer) {}
    func yhPlayerInterruptioned(_ player: YHPlayer, interruptionType type: YHPlayer.InterruptionType) {}
    func yhPlayerStatusChanged(_ player: YHPlayer, status: YHPlayer.PlayStatus) {}
}


open class YHPlayer: UIView {
    deinit {
        
        if let periodicTimeObserver = periodicTimeObserver {
            player.removeTimeObserver(periodicTimeObserver)
            self.periodicTimeObserver = nil
        }
        
        if let boundaryTimeObserver = boundaryTimeObserver {
            player.removeTimeObserver(boundaryTimeObserver)
            self.boundaryTimeObserver = nil
        }
        
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), context: &YHPlayerObserverContext)
        
        player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &YHPlayerObserverContext)
        
        player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), context: &YHPlayerObserverContext)
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
    }
    
   public override init(frame: CGRect) {
        super.init(frame: frame)
        customView()

    }
    
    //MARK: - public properties
    public weak var delegate: YHPlayerDelegate?
    /// 视频时长
    public private(set) var duration: TimeInterval  = 0
    
    /// 自定义配置占位图
    public var thumbImgBlock: ((UIImageView,UIImage?,String?) -> ())?
    
    //MARK: - private properties
    private var player: AVPlayer!
    private var canFullScreen: Bool { player != nil }
    private var animateDuration = 0.25
    
    /// 是否应该恢复播放
    private var shouldResumePlay = false
    
    /// 播放资源
    private var currentAsset: AVAsset!
    private var currentPlayerItem: AVPlayerItem!
    
    /// 播放配置
    private var currentItemConfig: YHPlayerItemConfig!
    
    /// 控制层手势处理
    private var tapGesture: UITapGestureRecognizer?
    
    /// 自定义控制层
    private var controlPanelView: UIView?
    
    private var periodicTimeObserver: Any?
    private var boundaryTimeObserver: Any?
    
    //MARK: 懒加载
    private lazy var containerView: UIView = {
        let containerView = UIView(frame: .zero)
        containerView.backgroundColor = .clear
        return containerView
    }()
    
    private lazy var playView: YHPlayerLayerView = {
        let playView = YHPlayerLayerView(frame: .zero)
        playView.isHidden = true
        playView.isUserInteractionEnabled = true
        playView.backgroundColor = .black
        return playView
    }()
    
    private lazy var thumbnailImgView: UIImageView = {
        let thumbnailImgView = UIImageView(frame: .zero)
        thumbnailImgView.clipsToBounds = true
        thumbnailImgView.contentMode = .scaleAspectFill
        return thumbnailImgView
    }()
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - 播放相关
extension YHPlayer: Play {
    /// 播放器状态
    public var playerStatus: YHPlayer.PlayStatus {
        switch player?.timeControlStatus {
        case .playing: return .playing
        case .paused: return .paused
        case .waitingToPlayAtSpecifiedRate: return .waitingToPlay
        default: return .unknown
        }
    }
    
    public var isPlaying: Bool { playerStatus == .playing }
    public var isPaused: Bool { playerStatus == .paused }
    public var isMuted: Bool { player.isMuted }

    /// 播放
    public func play() {
        player.play()
    }
    
    /// 重新播放
    public func replay() {
        seek(to: 0)
        play()
    }
    
    /// 暂停
    public func pause() {
        player.pause()
    }
    
    /// 静音
    public func toggleMute() {
        player.isMuted = !player.isMuted
    }
    
    /// 跳转到指定时间
    /// - Parameter specificedTime: 特定的时间
    public func seek(to specificedTime: TimeInterval) {
        player.seek(to: .init(seconds: specificedTime, preferredTimescale: .init(NSEC_PER_SEC)))
    }
}

//MARK: - 初始化
extension YHPlayer {
    
    /// 播放入口
    public func config(with itemConfig: YHPlayerItemConfig) {
        guard let videoURL = URL(string: itemConfig.videoURL) else { return }
        currentItemConfig = itemConfig
        
        configThumbImgView()
        
        configPlayer(videoURL)
    }
    
    /// 第一帧
    private func configThumbImgView() {
        if let thumbImgBlock = thumbImgBlock {
            thumbImgBlock(thumbnailImgView,currentItemConfig.thumbImg,currentItemConfig.thumbImgURL)
        }else {
            /// default操作
            if let thumbImg = currentItemConfig.thumbImg {
                thumbnailImgView.image = thumbImg.withRenderingMode(.alwaysOriginal)
            }
            if let thumbImgURL = currentItemConfig.thumbImgURL {
                URLSession.shared.dataTask(with: .init(string: thumbImgURL)!) { data, response, error in
                    guard data != nil else { return }
                    DispatchQueue.main.async {
                        self.thumbnailImgView.image = .init(data: data!)
                    }
                }.resume()
            }
        }
    }
    
    /// 初始化播放器
    private func configPlayer(_ videoURL: URL) {
        /// .playback:使用静音按钮时，不会影响音视频的播放
        try? AVAudioSession.sharedInstance().setCategory(.playback,mode: .moviePlayback)
        
        currentAsset = .init(url: videoURL)//AVURLAsset(url: videoURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey:true])
//        print(CMTimeGetSeconds(currentAsset.duration))
        
        currentPlayerItem = .init(asset: currentAsset)
        
        /// 也可以拿到duration
//        duration = CMTimeGetSeconds(currentAsset.duration)
        
        let assetLoadKeys = ["duration"]
        currentAsset.loadValuesAsynchronously(forKeys: assetLoadKeys) {[weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                var error: NSError?
                assetLoadKeys.forEach {
                    if $0 == "duration" && self.currentAsset.statusOfValue(forKey: $0, error: &error) == .loaded {
                        self.duration = CMTimeGetSeconds(self.currentAsset.duration)
                    }
                }
            }
        }
        player = AVPlayer(playerItem: currentPlayerItem)
        player.isMuted = currentItemConfig.isMuted
        
        playView.playerLayer.player = player
        
        registerPeriodicTimeObserver()
        registerTimeControlStatus()
        registerObserver()
        
//        registerBoundaryTimeObserver()
    }
}

//MARK: - 屏幕处理
extension YHPlayer {
    /// 全屏处理
    public func fullScreen(_ enabled: Bool, rotationTo orientation: UIInterfaceOrientation? = nil) {
        guard let keyWindow = getKeyWindow(),canFullScreen else { return }
        playView.removeFromSuperview()
        guard playView.superview == nil else { return }
        if enabled {
            keyWindow.addSubview(playView)
        }else {
            addSubview(playView)
        }
        playView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        if let orientation = orientation {
            UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        }
    }
    
    /// 旋转处理
    @objc private func screenRotationHandle(notification: Notification) {
        var enabled: Bool
        switch UIDevice.current.orientation {
        case .landscapeRight,.landscapeLeft,.portraitUpsideDown: enabled = true
        default: enabled = false
        }
        fullScreen(enabled)
    }
}

//MARK: - 控制层相关
extension YHPlayer {
    
    /// 点击playView
    @objc private func playViewTapGestureHandle(sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: animateDuration) {
            self.controlPanelView?.alpha = self.controlPanelView?.alpha == 0 ? 1 : 0
        }
    }
    
    /// 自定义控制层
    /// - Parameter controlView: 自定义view
    public func addCustomeControl(_ controlView: UIView,
                                  animated: Bool = false) {
        removeOldControlPanel()
        addNewControlPanel(controlView, animated: animated)
    }
    
    
    /// 自动隐藏控制层
    /// - Parameters:
    ///   - animated: 是否动画
    ///   - duration: 几秒后隐藏
    private func autoHideControlView(animated: Bool,
                                     duration: TimeInterval = 2) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            /// 解决可能控制层一添加，用户点击屏幕后，控制层快速消失
            guard self.controlPanelView?.alpha != 0 else { return }
            UIView.animate(withDuration: animated ? self.animateDuration : 0) {
                self.controlPanelView?.alpha = 0
                self.layoutIfNeeded()
            }
        }
    }
    
    /// 移除旧的
    private func removeOldControlPanel() {
        controlPanelView?.removeFromSuperview()
        controlPanelView = nil
        guard let tapGesture = tapGesture else { return }
        playView.removeGestureRecognizer(tapGesture)
        self.tapGesture = nil
        
    }
    /// 添加新的
    private func addNewControlPanel(_ controlView: UIView,
                                    animated: Bool = false) {
        controlPanelView = controlView
        playView.addSubview(controlView)
        UIView.animate(withDuration: animated ? animateDuration : 0) {
            controlView.snp.makeConstraints { make in
                make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
            }
            self.layoutIfNeeded()
        } completion: { finished in
            self.autoHideControlView(animated: true)
        }
        
        tapGesture = .init(target: self, action: #selector(playViewTapGestureHandle))
        playView.addGestureRecognizer(tapGesture!)
    }
}

//MARK: - KVO
extension YHPlayer {

    private func registerPeriodicTimeObserver() {
        periodicTimeObserver = player.addPeriodicTimeObserver(forInterval: .init(seconds: 1, preferredTimescale: .init(NSEC_PER_SEC)), queue: .main, using: { [weak self] time in
            guard let self = self else { return }
            let currentProgress = CMTimeGetSeconds(time)
            self.delegate?.yhPlayer(self, notifyCurrentProgress: currentProgress)
        })
    }
    
    private func registerTimeControlStatus() {
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.new,.old,.initial], context: &YHPlayerObserverContext)
    }
    
    private func registerBoundaryTimeObserver() {
        var times = [NSValue]()
         var currentTime = CMTime.zero
         let interval = CMTimeMultiplyByFloat64(currentAsset.duration, multiplier: 0.25)
         // Build boundary times at 25%, 50%, 75%, 100%
         while currentTime < currentAsset.duration {
             currentTime = currentTime + interval
             times.append(NSValue(time: currentTime))
         }
        boundaryTimeObserver = player?.addBoundaryTimeObserver(forTimes: times, queue: .main, using: {
            /// do something
        })
    }
    
    private func registerObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidEndPlayingHandle), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundHandle), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundHandle), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenRotationHandle), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(interruptionHandle), name: AVAudioSession.interruptionNotification, object: nil)

        player.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new,.old], context: &YHPlayerObserverContext)
        player.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.new,.old], context: &YHPlayerObserverContext)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
          guard context == &YHPlayerObserverContext else {
              super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
              return
          }
          if keyPath == #keyPath(AVPlayerItem.status) {
              var status: AVPlayerItem.Status
              if let statusNumber = change?[.newKey] as? Int {
                  status = .init(rawValue: statusNumber)!
              }else {
                  status = .unknown
              }
              switch status {
              case .readyToPlay:
                  playView.isHidden = false
                  /// 资源加载完毕，才能准备播放
                  if currentItemConfig.isAutoPlay == true {
                      player.play()
                  }
                  delegate?.yhPlayerReadyToPlay(self)
              case .failed:
                  /// 资源加载失败
                  delegate?.yhPlayerFailedToPlay(self, error: .failed)
              case .unknown:
                  /// 资源还没被加载
                  delegate?.yhPlayerFailedToPlay(self, error: .unknown)
              @unknown default:
                  delegate?.yhPlayerFailedToPlay(self, error: .unknown)
              }
          }else if keyPath == #keyPath(AVPlayer.timeControlStatus) {
              delegate?.yhPlayerStatusChanged(self, status: playerStatus)
          }else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
              if let array = change?[.newKey] as? [NSValue] {
                  guard let value = array.first else { return }
                  let totalBuffer = CMTimeGetSeconds(value.timeRangeValue.duration)
                  delegate?.yhPlayer(self, notifyBufferProgress: totalBuffer)
              }
          }
      }
}

//MARK: - 事件处理
private extension YHPlayer {
    
    /// 进入前台
    @objc func willEnterForegroundHandle() {
        if shouldResumePlay {
            shouldResumePlay = !shouldResumePlay
            player.play()
        }
    }
    /// 进入后台
    @objc func didEnterBackgroundHandle() {
        guard playerStatus == .playing || playerStatus == .waitingToPlay else { return }
        shouldResumePlay = true
    }
    
    /// 播放完毕
    @objc func playerDidEndPlayingHandle() {
        delegate?.yhPlayerDidEndPlaying(self)
    }
    
    /// 程序中断
    @objc func interruptionHandle(notification: Notification) {
        var interruptionType: YHPlayer.InterruptionType!
        if let userInfo = notification.userInfo as? [String:Any],
        let typeNumber = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
         let type = AVAudioSession.InterruptionType(rawValue: typeNumber){
            switch type {
            case .began: interruptionType = .begin
            case .ended: interruptionType = .end
            default: break
            }
        }
        delegate?.yhPlayerInterruptioned(self, interruptionType: interruptionType)
    }
}

//MARK: 布局相关
private extension YHPlayer {
    //MARK: 填充View
    func customView() {
        addSubview(containerView)
        containerView.addSubview(thumbnailImgView)
        containerView.addSubview(playView)
        layoutSubAllViews()
    }
    
    //MARK: 适配View
    func layoutSubAllViews() {
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        thumbnailImgView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        playView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
    }
}

//MARK: - 相关枚举
public extension YHPlayer {
    enum PlayStatus {
        case playing
        case paused
        /**
         case noItemToPlay
         case toMinimizeStalls
         case evaluatingBufferingRate
         
         @available(iOS 15, *)
         case interstitialEvent
         
         @available(iOS 15, *)
         case waitingForCoordinatedPlayback
         */
        case waitingToPlay
        case unknown
    }

    enum Error {
        case failed
        case unknown
    }
    enum InterruptionType: UInt {
        case begin
        case end
    }
}



