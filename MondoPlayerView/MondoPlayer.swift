//
//  MondoPlayer.swift
//  MondoPlayer
//
//  Created by Christopher Graham on 7/14/15.
//  Copyright (c) 2015 MoltenViper. All rights reserved.
//

import AVFoundation
import CoreMedia
import UIKit

protocol MondoPlayerDelegate {
    func mondoPlayer(mondoPlayer: MondoPlayer, changedState: MondoPlayerState)
    func mondoPlayer(mondoPlayer: MondoPlayer, encounteredError: NSError)
}

enum MondoPlayerEndAction: Int {
    case Stop = 1
    case Loop
}

enum MondoPlayerState: Int {
    case Stopped = 1
    case Loading, Playing, Paused
}

@IBDesignable class MondoPlayer: UIView {

    
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
    
    var delegate : MondoPlayerDelegate?
    
    var endAction : MondoPlayerEndAction
    
    var state : MondoPlayerState {
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
    
    var URL : NSURL? {
        didSet {
            self.destroyPlayer()
        }
    }
    
    var volume : Float {
        didSet {
            if (self.player != nil) {
                self.player!.volume = self.volume
            }
        }
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Initializing
    
    
    deinit {
        
        log.trace("entered")

        self.destroyPlayer()
        
    }
    
    // -------------------------------------------------------------
    
    override init(frame: CGRect) {
        
        log.trace("entered")

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
    
    required init(coder aDecoder: NSCoder) {
        
        log.trace("entered")

        self.endAction = MondoPlayerEndAction.Stop
        self.state = MondoPlayerState.Stopped;
        self.volume = 1.0;
        self.isBufferEmpty = false
        self.isLoaded = false
        super.init(coder: aDecoder)
        
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        
        log.trace("entered")
        
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
        
        log.trace("entered")
        
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
        
        log.trace("entered")
        
        self.removeObservers();
        self.player = nil
//        self.playerLayer?.removeFromSuperlayer()
//        self.playerLayer = nil
        self.setStateNotifyingDelegate(MondoPlayerState.Stopped)
        
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Player Notifications
    
    func playerFailed(notification: NSNotification) {
        
        log.trace("entered")
        
        self.destroyPlayer();
        self.delegate?.mondoPlayer(self, encounteredError: NSError(domain: "MondoPlayer", code: 1, userInfo: [NSLocalizedDescriptionKey : "An unknown error occured."]))
        
    }
    
    func playerPlayedToEnd(notification: NSNotification) {
        
        log.trace("entered")
        
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
        
        log.trace("entered")
        
        self.player?.addObserver(self, forKeyPath: "rate", options: nil, context: nil)
        self.player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: nil, context: nil)
        self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: nil, context: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerFailed:"), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: self.player?.currentItem)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerPlayedToEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player?.currentItem)
        
    }
    
    // -------------------------------------------------------------
    
    func removeObservers() {
        
        log.trace("entered")
        
        self.player?.removeObserver(self, forKeyPath: "rate")
        self.player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        self.player?.currentItem?.removeObserver(self, forKeyPath: "status")

        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    // -------------------------------------------------------------
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<Void>)  {
        
        log.trace("entered")
        
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
    
    func play() {
        
        log.trace("entered")
        
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
    
    func pause() {
        
        log.trace("entered")
        
        switch self.state {
        case MondoPlayerState.Playing, MondoPlayerState.Loading:
            self.player?.pause()
        default:
            break
            
        }
        
    }
    
    // -------------------------------------------------------------
    
    func stop() {
        
        log.trace("entered")
        
        if (self.state == MondoPlayerState.Stopped) {
            return
        }
        self.destroyPlayer()
        
    }
    
    // -------------------------------------------------------------
    
    // MARK: - Getters & Setters
    
    func setStateNotifyingDelegate(state: MondoPlayerState) {
        
        log.trace("entered")
        
        self.state = state
        self.delegate?.mondoPlayer(self, changedState: state)
        
    }
    
}
