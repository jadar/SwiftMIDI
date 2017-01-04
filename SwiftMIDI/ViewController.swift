//
//  ViewController.swift
//  SwiftMIDI
//
//  Created by Jacob Rhoda on 12/19/16.
//  Copyright © 2016 Jadar. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var soundFontName = "TimGM6mb"

    var midi: MIDI!
//    var player: AVMIDIPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        midi = MIDI(soundBankURL: Bundle.main.url(forResource: soundFontName, withExtension: "sf2")!)
//        player = try! AVMIDIPlayer(contentsOf: Bundle.main.url(forResource: "1a.compiled", withExtension: "mid")!, soundBankURL: Bundle.main.url(forResource: "TimGM6mb", withExtension: "sf2")!)
        
        let midiFile1 = Bundle.main.url(forResource: "1a.1", withExtension: "mid")!
        midi.loadMIDISequence(from: midiFile1)
        let midiFile2 = Bundle.main.url(forResource: "1a.2", withExtension: "mid")!
        midi.loadMIDISequence(from: midiFile2)
        let midiFile3 = Bundle.main.url(forResource: "1a.3", withExtension: "mid")!
        midi.loadMIDISequence(from: midiFile3)
        let midiFile4 = Bundle.main.url(forResource: "1a.4", withExtension: "mid")!
        midi.loadMIDISequence(from: midiFile4)
    }
    
    @IBAction func playPressed() {
        midi.play()
    }
    @IBAction func sliderChanged(_ sender: UISlider) {
        midi.setVolume(sender.value, forTrack: sender.tag)
    }
}

