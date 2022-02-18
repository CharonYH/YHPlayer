//
//  YHPlayerControlView.swift
//  XiaoBaiPlayer
//
//  Created by XiaoBai on 2022/2/8.
//

import UIKit
import SnapKit

let RATIO_WIDHT750  = UIScreen.main.bounds.width / 375.0

protocol YHPlayerControlViewDelegate: NSObjectProtocol {
    func yhControlView(_ controlView: YHPlayerControlView, didClickMutedBtn: UIButton)
    func yhControlView(_ controlView: YHPlayerControlView, didClickfullScreenBtn fullScreenBtn: UIButton)
    func yhControlView(_ controlView: YHPlayerControlView, didClickPlayBtn: UIButton)
    func yhControlView(_ controlView: YHPlayerControlView, sliderValueChanged slider: UISlider)
    func yhControlView(_ controlView: YHPlayerControlView, sliderTouchDown slider: UISlider)
}

extension YHPlayerControlViewDelegate {
    func yhControlView(_ controlView: YHPlayerControlView, didClickMutedBtn: UIButton) {}
    func yhControlView(_ controlView: YHPlayerControlView, didClickfullScreenBtn fullScreenBtn: UIButton) {}
    func yhControlView(_ controlView: YHPlayerControlView, didClickPlayBtn: UIButton) {}
    func yhControlView(_ controlView: YHPlayerControlView, sliderValueChanged slider: UISlider) {}
    func yhControlView(_ controlView: YHPlayerControlView, sliderTouchDown slider: UISlider) {}
}


class YHPlayerControlView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        customView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: YHPlayerControlViewDelegate?
    
    func updateProgress(with value: TimeInterval, duration: TimeInterval) {
        progressSlider.setValue(Float(value), animated: true)
        progressSlider.maximumValue = Float(duration)
        setTotalProgress(with: duration)
    }
    
    func setTotalProgress(with value: TimeInterval) {
        totalProgressLbl.text = getPlayTime(from: value)
    }
    
    //MARK: 填充View
    private func customView() {
        addSubview(playBtn)
        addSubview(cacheProgressLbl)
        addSubview(progressSlider)
        addSubview(totalProgressLbl)
        addSubview(fullScreenBtn)
        addSubview(muteBtn)
        layoutAllSubViews()
    }
    
    //MARK: 适配View
    private func layoutAllSubViews() {
        playBtn.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.size.equalTo(CGSize(width: 60*RATIO_WIDHT750, height: 60*RATIO_WIDHT750))
        }
        cacheProgressLbl.snp.makeConstraints { make in
            make.left.equalTo(10*RATIO_WIDHT750)
            make.bottom.equalTo(0)
        }
        progressSlider.snp.makeConstraints { make in
            make.left.equalTo(cacheProgressLbl.snp.right).offset(15*RATIO_WIDHT750)
            make.right.equalTo(totalProgressLbl.snp.left).offset(-15*RATIO_WIDHT750)
            make.centerY.equalTo(cacheProgressLbl)
        }
        totalProgressLbl.snp.makeConstraints { make in
            make.right.equalTo(fullScreenBtn.snp.left).offset(0*RATIO_WIDHT750)
            make.bottom.equalTo(cacheProgressLbl)
        }
        fullScreenBtn.snp.makeConstraints { make in
            make.right.equalTo(-10*RATIO_WIDHT750)
            make.centerY.equalTo(cacheProgressLbl)
            make.size.equalTo(CGSize(width: 44*RATIO_WIDHT750, height: 44*RATIO_WIDHT750))
        }
        muteBtn.snp.makeConstraints { make in
            make.right.equalTo(fullScreenBtn)
            make.bottom.equalTo(fullScreenBtn.snp.top).offset(0)
            make.size.equalTo(fullScreenBtn)
        }
    }
    
    //MARK: 懒加载
    private lazy var cacheProgressLbl: UILabel = {
        let cacheProgressLbl = UILabel(frame: .zero)
        cacheProgressLbl.text = "00:00"
        cacheProgressLbl.textColor = .white
        cacheProgressLbl.textAlignment = .center
        cacheProgressLbl.font = .systemFont(ofSize: 14)
        return cacheProgressLbl
    }()
    
    private lazy var progressSlider: UISlider = {
        let progressSlider = UISlider(frame: .zero)
        /// 避免拖动就造成事件的传递
        progressSlider.isContinuous = false
        progressSlider.value = 0
        progressSlider.tintColor = .orange
        progressSlider.thumbTintColor = .white
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        return progressSlider
    }()
    
    private lazy var totalProgressLbl: UILabel = {
        let totalProgressLbl = UILabel(frame: .zero)
        totalProgressLbl.text = ""
        totalProgressLbl.textColor = .white
        totalProgressLbl.textAlignment = .center
        totalProgressLbl.font = .systemFont(ofSize: 14)
        return totalProgressLbl
    }()
    
    private lazy var fullScreenBtn: UIButton = {
        let fullScreenBtn = UIButton(frame: .zero)
        fullScreenBtn.tag = 2
        fullScreenBtn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        fullScreenBtn.tintColor = .white
        fullScreenBtn.setImage(.init(named: "yh_no_fullScreen")?.withRenderingMode(.alwaysTemplate), for: .normal)
        fullScreenBtn.setImage(.init(named: "yh_is_fullScreen")?.withRenderingMode(.alwaysTemplate), for: .selected)
        return fullScreenBtn
    }()
    
    private(set) lazy var muteBtn: UIButton = {
        let muteBtn = UIButton(frame: .zero)
        muteBtn.tag = 1
        muteBtn.tintColor = .white
        muteBtn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        muteBtn.setImage(.init(named: "yh_is_muted")?.withRenderingMode(.alwaysTemplate), for: .normal)
        muteBtn.setImage(.init(named: "yh_no_muted")?.withRenderingMode(.alwaysTemplate), for: .selected)
        return muteBtn
    }()
    
    private(set) lazy var playBtn: UIButton = {
        let playBtn = UIButton(frame: .zero)
        playBtn.tag = 0
        playBtn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        playBtn.tintColor = .white
        playBtn.setImage(.init(named: "yh_pause")?.withRenderingMode(.alwaysTemplate), for: .normal)
        playBtn.setImage(.init(named: "yh_play")?.withRenderingMode(.alwaysTemplate), for: .selected)
        return playBtn
    }()
    private lazy var dataComponentsFormatter: DateComponentsFormatter = {
        let dataComponentsFormatter = DateComponentsFormatter()
        dataComponentsFormatter.allowedUnits = [.hour,.minute,.minute]
        return dataComponentsFormatter
    }()
}

// MARK: - target event
private extension YHPlayerControlView {
    @objc func btnClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let btnType = YHPlayerControlView.BtnType(rawValue: sender.tag)!
        switch btnType {
        case .play:
            delegate?.yhControlView(self, didClickPlayBtn: sender)
        case .muted:
            delegate?.yhControlView(self, didClickMutedBtn: sender)
        case .fullScreen:
            delegate?.yhControlView(self, didClickfullScreenBtn: sender)
        }
    }
    
    @objc func sliderValueChanged(sender: UISlider) {
        delegate?.yhControlView(self, sliderValueChanged: sender)
    }
    @objc func sliderTouchDown(sender: UISlider) {
        delegate?.yhControlView(self, sliderTouchDown: sender)
    }
}

private extension YHPlayerControlView {
    func getPlayTime(from timeInterval: TimeInterval) -> String {
        let value: TimeInterval = timeInterval
        let minute = Int(ceil(value) / 60)
        var seconds = Int(floor(value).truncatingRemainder(dividingBy: 60))
        if value - Double(minute * 60) - Double(seconds) >= 0.5 {
            seconds += 1
        }
        return String(format: "%02d:%02d", minute,seconds)
    }
}

// MARK: - BtnType
extension YHPlayerControlView {
    enum BtnType: Int {
        case play, muted, fullScreen
    }
}
