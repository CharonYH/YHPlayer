# YHPlayer
An easy-to-use video player based on swift language
=======

[![CI Status](https://img.shields.io/travis/YEHAN/YHPlayer.svg?style=flat)](https://travis-ci.org/YEHAN/YHPlayer)
[![Version](https://img.shields.io/cocoapods/v/YHPlayer.svg?style=flat)](https://cocoapods.org/pods/YHPlayer)
[![License](https://img.shields.io/cocoapods/l/YHPlayer.svg?style=flat)](https://cocoapods.org/pods/YHPlayer)
[![Platform](https://img.shields.io/cocoapods/p/YHPlayer.svg?style=flat)](https://cocoapods.org/pods/YHPlayer)

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
```
1.create YHPlayer
        let playView = YHPlayer(frame: .zero)
        playView.delegate = self
```

```
2.create YHPlayerItemConfig
        let itemConfig = YHPlayerItemConfig(videoURL: videoURL1,
                                            isMuted: false,
                                            isAutoPlay: false,
                                            thumbImg: .init(named: "thumbimg"))
```

```
3.set itemConfig to player
        playView.config(with: itemConfig)
```

```
4.custome your controlPanel
        playView.addCustomeControl(controlView)
```
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

YEHAN, 2436567084@qq.com

## License

YHPlayer is available under the MIT license. See the LICENSE file for more info.
>>>>>>> 190e7f6 (Initial commit)
