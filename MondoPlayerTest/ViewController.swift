//
//  ViewController.swift
//  MondoPlayerTest
//
//  Created by Christopher Graham on 7/25/15.
//  Copyright (c) 2015 MoltenViper. All rights reserved.
//

import UIKit
import MondoPlayerView

class ViewController: UIViewController {

    @IBOutlet weak var mondoPlayer: MondoPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStationPlayer();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        // start playing a stream
        mondoPlayer.play()
    }

    func setupStationPlayer() {
        mondoPlayer.delegate = self
        mondoPlayer.URL = URL(string:"https://yp.shoutcast.com/sbin/tunein-station.m3u?id=1516098")
    }
    
}

extension ViewController: MondoPlayerDelegate {
    func mondoPlayer(_ mondoPlayer: MondoPlayer, changedState: MondoPlayerState) {
        print("player changed state: \(changedState)")
    }
    
    func mondoPlayer(_ mondoPlayer: MondoPlayer, encounteredError: NSError) {
        print("player error: " + encounteredError.localizedDescription)
    }
}
