//
//  MondoPlayer.swift
//  MondoPlayer
//
//  Created by Christopher Graham on 7/14/15.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 MoltenViper. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import AVFoundation
import CoreMedia
import UIKit

public protocol MondoPlayerDelegate {
    func mondoPlayer(_ mondoPlayer: MondoPlayer, changedState: MondoPlayerState)
    func mondoPlayer(_ mondoPlayer: MondoPlayer, encounteredError: NSError)
}

public enum MondoPlayerEndAction: Int {
    case stop = 1
    case loop
}

public enum MondoPlayerState: Int {
    case stopped = 1
    case loading, playing, paused
}


open class MondoPlayer: UIView {

    // -------------------------------------------------------------

    // MARK: - Property Viewers
    
    var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Private
    
    var player : AVPlayer?
//    var playerLayer : AVPlayerLayer?
    var playerItem : AVPlayerItem?
    
    var actionButton : UIButton?
    
    var isBufferEmpty : Bool
    var isLoaded : Bool
    
    // -------------------------------------------------------------
    
    // MARK: - Public
    
    open var delegate : MondoPlayerDelegate?
    
    open var endAction : MondoPlayerEndAction
    
    open var state : MondoPlayerState {
        didSet {
            switch (self.state) {
            case .paused, .stopped:
                self.actionButton?.removeTarget(self, action: #selector(MondoPlayer.pause), for: UIControlEvents.touchUpInside)
                self.actionButton?.addTarget(self, action: #selector(MondoPlayer.play), for: UIControlEvents.touchUpInside)
            case .loading, .playing:
                self.actionButton?.removeTarget(self, action: #selector(MondoPlayer.play), for: UIControlEvents.touchUpInside)
                self.actionButton?.addTarget(self, action: #selector(MondoPlayer.pause), for: UIControlEvents.touchUpInside)
            }
        }
    }
    
    open var URL : Foundation.URL? {
        didSet {
            self.destroyPlayer()
        }
    }
    
    open var volume : Float {
        didSet {
            if (self.player != nil) {
                self.player!.volume = self.volume
            }
        }
    }
    
    open var maximumDuration: TimeInterval! {
        get {
            if let playerItem = self.playerItem {
                return CMTimeGetSeconds(playerItem.duration)
            } else {
                return CMTimeGetSeconds(kCMTimeIndefinite)
            }
        }
    }

    open var currentTime: TimeInterval! {
        get {
            if let playerItem = self.playerItem {
                return CMTimeGetSeconds(playerItem.currentTime())
            } else {
                return CMTimeGetSeconds(kCMTimeIndefinite)
            }
        }
    }

    // -------------------------------------------------------------
    
    // MARK: - Initializing
    
    
    deinit {
        
        self.destroyPlayer()
        
    }
    
    // -------------------------------------------------------------
    
    public override init(frame: CGRect) {
        
        self.endAction = MondoPlayerEndAction.stop
        self.state = MondoPlayerState.stopped;
        self.volume = 1.0;
        
        self.isBufferEmpty = false
        self.isLoaded = false
        
        super.init(frame: frame)
        
        let actionButton : UIButton = UIButton()
        self.addSubview(actionButton)
        self.actionButton = actionButton
        
    }
    
    // -------------------------------------------------------------
    
    required public init?(coder aDecoder: NSCoder) {
        
        self.endAction = MondoPlayerEndAction.stop
        self.state = MondoPlayerState.stopped;
        self.volume = 1.0;
        self.isBufferEmpty = false
        self.isLoaded = false
        super.init(coder: aDecoder)
        
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Layout
    
    override open func layoutSubviews() {
        
        if ((self.actionButton) != nil) {
            self.actionButton!.frame = self.bounds
        }
        
//        if ((self.playerLayer) != nil) {
//            self.playerLayer!.frame = self.bounds
//        }
        
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Player Operations
    
    func setupPlayer() {
        
        if self.URL == nil {
            return;
        }
        
        self.destroyPlayer()
        
        playerItem = AVPlayerItem(url: self.URL!)
        
        let player : AVPlayer = AVPlayer(playerItem: playerItem!)
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        player.volume = self.volume
        self.player = player;
        
//        let playerLayer : AVPlayerLayer = AVPlayerLayer(player: player)
//        self.layer.addSublayer(playerLayer)
//        self.playerLayer = playerLayer
        
        player.play()
        
        self.addObservers()
        self.setNeedsLayout()
        
    }
    
    // -------------------------------------------------------------
    
    func destroyPlayer() {
        
        self.removeObservers();
        self.player = nil
//        self.playerLayer?.removeFromSuperlayer()
//        self.playerLayer = nil
        self.setStateNotifyingDelegate(MondoPlayerState.stopped)
        
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Player Notifications
    
    @objc func playerFailed(_ notification: Notification) {
        
        self.destroyPlayer();
        self.delegate?.mondoPlayer(self, encounteredError: NSError(domain: "MondoPlayer", code: 1, userInfo: [NSLocalizedDescriptionKey : "An unknown error occured."]))
        
    }

    // -------------------------------------------------------------

    @objc func playerPlayedToEnd(_ notification: Notification) {
        
        switch self.endAction {
        case .loop:
            self.player?.currentItem?.seek(to: kCMTimeZero)
        case .stop:
            self.destroyPlayer()
        }
        
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Observers
    
    func addObservers() {
        
        self.player?.addObserver(self, forKeyPath: "rate", options: [], context: nil)
        self.player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: [], context: nil)
        self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: [], context: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(MondoPlayer.playerFailed(_:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: self.player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(MondoPlayer.playerPlayedToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        
    }
    
    // -------------------------------------------------------------
    
    func removeObservers() {
        
        self.player?.removeObserver(self, forKeyPath: "rate")
        self.player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        self.player?.currentItem?.removeObserver(self, forKeyPath: "status")

        NotificationCenter.default.removeObserver(self)
        
    }
    
    // -------------------------------------------------------------
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)  {
        
        let obj = object as? NSObject
        
        if obj == self.player {
            if keyPath == "rate" {
                let rate = self.player?.rate
                if !self.isLoaded {
                    self.setStateNotifyingDelegate(MondoPlayerState.loading)
                } else if rate == 1.0 {
                    self.setStateNotifyingDelegate(MondoPlayerState.playing)
                } else if rate == 0.0 {
                    if self.isBufferEmpty {
                        self.setStateNotifyingDelegate(MondoPlayerState.loading)
                    } else {
                        self.setStateNotifyingDelegate(MondoPlayerState.paused)
                    }
                }
            }
        } else if obj == self.player?.currentItem {
            if keyPath == "status" {
                let status : AVPlayerItemStatus? = self.player?.currentItem?.status
                if status == AVPlayerItemStatus.failed {
                    self.destroyPlayer()
                    self.delegate?.mondoPlayer(self, encounteredError: NSError(domain: "MondoPlayer", code: 1, userInfo: [NSLocalizedDescriptionKey : "An unknown error occured."]))
                } else if status == AVPlayerItemStatus.readyToPlay {
                    self.isLoaded = true
                    self.setStateNotifyingDelegate(MondoPlayerState.playing)
                }
            } else if keyPath == "playbackBufferEmpty" {
                
                let empty : Bool? = self.player?.currentItem?.isPlaybackBufferEmpty
                if empty != nil {
                    self.isBufferEmpty = true
                } else {
                    self.isBufferEmpty = false
                }
            }
        }
        
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Player Actions

    @objc open func play() {
        
        switch self.state {
        case MondoPlayerState.paused:
            self.player?.play()
        case MondoPlayerState.stopped:
            self.setupPlayer();
        default:
            break
        }
        
    }
    
    // -------------------------------------------------------------
    
    @objc open func pause() {
        
        switch self.state {
        case MondoPlayerState.playing, MondoPlayerState.loading:
            self.player?.pause()
        default:
            break
            
        }
        
    }
    
    // -------------------------------------------------------------
    
    open func stop() {
        
        if (self.state == MondoPlayerState.stopped) {
            return
        }
        self.destroyPlayer()
        
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Getters & Setters
    
    func setStateNotifyingDelegate(_ state: MondoPlayerState) {
        
        self.state = state
        self.delegate?.mondoPlayer(self, changedState: state)
        
    }
    
}
