//
//  ViewController.swift
//  MondoPlayerTest
//
//  Created by Christopher Graham on 7/25/15.
//  Copyright (c) 2015 MoltenViper. All rights reserved.
//

import UIKit
import MondoPlayerView

class ViewController: UIViewController, MondoPlayerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mondoPlayer(mondoPlayer: MondoPlayer, changedState: MondoPlayerState) {
        // TODO
    }
    
    func mondoPlayer(mondoPlayer: MondoPlayer, encounteredError: NSError) {
        // TODO
    }

}

