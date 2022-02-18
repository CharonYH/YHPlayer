# YHPlayer
An easy-to-use video player based on swift language
=======

[![CI Status](https://img.shields.io/travis/YEHAN/YHPlayer.svg?style=flat)](https://travis-ci.org/YEHAN/YHPlayer)
[![Version](https://img.shields.io/cocoapods/v/YHPlayer.svg?style=flat)](https://cocoapods.org/pods/YHPlayer)
[![License](https://img.shields.io/cocoapods/l/YHPlayer.svg?style=flat)](https://cocoapods.org/pods/YHPlayer)
[![Platform](https://img.shields.io/cocoapods/p/YHPlayer.svg?style=flat)](https://cocoapods.org/pods/YHPlayer)

## Features
- [x] Plays local media or streams remote media over HTTP
- [x] Custom UI control layer screen
- [x] Support screen rotation 
- [x] Simple API
- [x] Clear delegate method  
- [x] Audio Default is muted
- [x] AutoPlay Default is False 
## Requirements
iOS 11.0 or later  
xcode 11.0 or later

## Installation
YHPlayer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
target 'YourProductName' do
    pod 'YHPlayer'
    ...
```

Install pods
```
$ pod install
```
And then import `import YHPlayer` where you use.

## How to use
```swift
1.create YHPlayer
        let playView = YHPlayer(frame: .zero)
        playView.delegate = self
```

```swift
2.create YHPlayerItemConfig
        let itemConfig = YHPlayerItemConfig(videoURL: videoURL1,
                                            isMuted: false,
                                            isAutoPlay: false,
                                            thumbImg: .init(named: "thumbimg"))
```

```swift
3.set itemConfig to player
        playView.config(with: itemConfig)
```

```swift
4.custome your controlPanel
        playView.addCustomeControl(controlView)
```

## YHPlayerDelegate
```swift
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
```

## Run result
<img src="./img/result.gif" width="240px" height="426px"/>
## Author

YEHAN, 2436567084@qq.com

## License

YHPlayer is available under the MIT license. See the LICENSE file for more info.
>>>>>>> 190e7f6 (Initial commit)
