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
    func mondoPlayer(mondoPlayer: MondoPlayer, changedState: MondoPlayerState)
    func mondoPlayer(mondoPlayer: MondoPlayer, encounteredError: NSError)
}

public enum MondoPlayerEndAction: Int {
    case Stop = 1
    case Loop
}

public enum MondoPlayerState: Int {
    case Stopped = 1
    case Loading, Playing, Paused
}

@IBDesignable public class MondoPlayer: UIView {

    
    // -------------------------------------------------------------

    // MARK: - Property Viewers
    
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Private
    
    var player : AVPlayer?
//    var playerLayer : AVPlayerLayer?
    
    var actionButton : UIButton?
    
    var isBufferEmpty : Bool
    var isLoaded : Bool
    
    // -------------------------------------------------------------
    
    // MARK: - Public
    
    public var delegate : MondoPlayerDelegate?
    
    public var endAction : MondoPlayerEndAction
    
    public var state : MondoPlayerState {
        didSet {
            switch (self.state) {
            case .Paused, .Stopped:
                self.actionButton?.removeTarget(self, action: Selector("pause"), forControlEvents: UIControlEvents.TouchUpInside)
                self.actionButton?.addTarget(self, action: Selector("play"), forControlEvents: UIControlEvents.TouchUpInside)
            case .Loading, .Playing:
                self.actionButton?.removeTarget(self, action: Selector("play"), forControlEvents: UIControlEvents.TouchUpInside)
                self.actionButton?.addTarget(self, action: Selector("pause"), forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
    }
    
    public var URL : NSURL? {
        didSet {
            self.destroyPlayer()
        }
    }
    
    public var volume : Float {
        didSet {
            if (self.player != nil) {
                self.player!.volume = self.volume
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
        
        self.endAction = MondoPlayerEndAction.Stop
        self.state = MondoPlayerState.Stopped;
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
        
        self.endAction = MondoPlayerEndAction.Stop
        self.state = MondoPlayerState.Stopped;
        self.volume = 1.0;
        self.isBufferEmpty = false
        self.isLoaded = false
        super.init(coder: aDecoder)
        
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Layout
    
    override public func layoutSubviews() {
        
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
        
        let playerItem : AVPlayerItem = AVPlayerItem(URL: self.URL!)
        
        let player : AVPlayer = AVPlayer(playerItem: playerItem)
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
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
        self.setStateNotifyingDelegate(MondoPlayerState.Stopped)
        
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Player Notifications
    
    func playerFailed(notification: NSNotification) {
        
        self.destroyPlayer();
        self.delegate?.mondoPlayer(self, encounteredError: NSError(domain: "MondoPlayer", code: 1, userInfo: [NSLocalizedDescriptionKey : "An unknown error occured."]))
        
    }
    
    func playerPlayedToEnd(notification: NSNotification) {
        
        switch self.endAction {
        case .Loop:
            self.player?.currentItem?.seekToTime(kCMTimeZero)
        case .Stop:
            self.destroyPlayer()
        }
        
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Observers
    
    func addObservers() {
        
        self.player?.addObserver(self, forKeyPath: "rate", options:  [], context: nil)
        self.player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options:  [], context: nil)
        self.player?.currentItem?.addObserver(self, forKeyPath: "status", options:  [], context: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerFailed:"), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: self.player?.currentItem)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerPlayedToEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player?.currentItem)
        
    }
    
    // -------------------------------------------------------------
    
    func removeObservers() {
        
        self.player?.removeObserver(self, forKeyPath: "rate")
        self.player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        self.player?.currentItem?.removeObserver(self, forKeyPath: "status")

        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    // -------------------------------------------------------------
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String:AnyObject]?, context: UnsafeMutablePointer<Void>)  {
        
        let obj = object as? NSObject
        
        if obj == self.player {
            if keyPath == "rate" {
                let rate = self.player?.rate
                if !self.isLoaded {
                    self.setStateNotifyingDelegate(MondoPlayerState.Loading)
                } else if rate == 1.0 {
                    self.setStateNotifyingDelegate(MondoPlayerState.Playing)
                } else if rate == 0.0 {
                    if self.isBufferEmpty {
                        self.setStateNotifyingDelegate(MondoPlayerState.Loading)
                    } else {
                        self.setStateNotifyingDelegate(MondoPlayerState.Paused)
                    }
                }
            }
        } else if obj == self.player?.currentItem {
            if keyPath == "status" {
                let status : AVPlayerItemStatus? = self.player?.currentItem?.status
                if status == AVPlayerItemStatus.Failed {
                    self.destroyPlayer()
                    self.delegate?.mondoPlayer(self, encounteredError: NSError(domain: "MondoPlayer", code: 1, userInfo: [NSLocalizedDescriptionKey : "An unknown error occured."]))
                } else if status == AVPlayerItemStatus.ReadyToPlay {
                    self.isLoaded = true
                    self.setStateNotifyingDelegate(MondoPlayerState.Playing)
                }
            } else if keyPath == "playbackBufferEmpty" {
                
                let empty : Bool? = self.player?.currentItem?.playbackBufferEmpty
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
    
    public func play() {
        
        switch self.state {
        case MondoPlayerState.Paused:
            self.player?.play()
        case MondoPlayerState.Stopped:
            self.setupPlayer();
        default:
            break
        }
        
    }
    
    // -------------------------------------------------------------
    
    public func pause() {
        
        switch self.state {
        case MondoPlayerState.Playing, MondoPlayerState.Loading:
            self.player?.pause()
        default:
            break
            
        }
        
    }
    
    // -------------------------------------------------------------
    
    public func stop() {
        
        if (self.state == MondoPlayerState.Stopped) {
            return
        }
        self.destroyPlayer()
        
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Getters & Setters
    
    func setStateNotifyingDelegate(state: MondoPlayerState) {
        
        self.state = state
        self.delegate?.mondoPlayer(self, changedState: state)
        
    }
    
}
