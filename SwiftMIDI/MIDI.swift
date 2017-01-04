//
//  MIDI.swift
//  SwiftMIDI
//
//  Created by Jacob Rhoda on 12/19/16.
//  Copyright © 2016 Jadar. All rights reserved.
//

import Foundation
import AVFoundation

//struct WeakThing<T: AnyObject>{
//    weak var value: T?
//}

class MIDI {
    let soundBankURL: URL
    let engine = AVAudioEngine()
    var tracksAndSamplers: [(AVMusicTrack, AVAudioUnitSampler?)] = []
    let sequencer: AVAudioSequencer
    
    func setSessionPlayback(isActive active: Bool) {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("could not set session category")
            print(error)
        }
        
        do {
            try session.setActive(active)
        } catch {
            print("could not make session active")
            print(error)
        }
    }
    
    init(soundBankURL: URL) {
        self.soundBankURL = soundBankURL
        
        let mainMixer = engine.mainMixerNode
        let output = engine.outputNode
        engine.connect(mainMixer, to: output, format: nil)
        sequencer = AVAudioSequencer(audioEngine: engine)
        
        engine.prepare()
    }
    
    private func addSampler(sampler: AVAudioUnitSampler) {
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        loadInstrument(into: sampler, withPreset: 0)
    }
    
    private func loadInstrument(into sampler: AVAudioUnitSampler, withPreset preset: UInt8) {
        do {
            try sampler.loadSoundBankInstrument(at: soundBankURL,
                                                program: preset,
                                                bankMSB: 0x79,
                                                bankLSB: 0)
        } catch {
            print("error loading sound bank instrument")
            print(error)
        }
    }
    
    // MARK: >>>> THE ISSUE IS HERE!
    func loadMIDISequence(from url: URL) {
        let sampler = AVAudioUnitSampler()
        addSampler(sampler: sampler)
        
        let startingCount = sequencer.tracks.count
        
        // Try to load more tracks. Assuming this is the same as `MusicSequenceFileLoad`, except that function
        // will actually add the tracks separate from the current tracks in the sequence.
        do {
            try sequencer.load(from: url, options: [])
        } catch {
            print("failed to load")
            return
        }
        
        let endingCount = sequencer.tracks.count
        
        print("Starting: \(startingCount), Ending: \(endingCount)")
        
//        if let last = sequencer.tracks.last {
//            print(last)
//            tracksAndSamplers.append((last, nil))
//        }

        // This method will strongly hold the tracks. This will cause the sequencer.tracks to have 
        // the correct count, but tracksAndSamplers is weird. I suspect they don't all acutally have
        // the events, etc. Weird memory things are going on.
        //
        // Comment this out, and also line 125 (calling `configureSampler`) to see the Starting/Ending
        // when we don't retain the tracks.
        for track in sequencer.tracks where !tracksAndSamplers.contains(where: { $0.0 == track }) {
            print(track)
            tracksAndSamplers.append((track, sampler))
        }
    }
    
    func configureSampler() {
        for (index, (track, _)) in tracksAndSamplers.enumerated() {
            let sampler = AVAudioUnitSampler()
            addSampler(sampler: sampler)
            
            track.destinationAudioUnit = sampler
            tracksAndSamplers[index].1 = sampler
        }
        
    }
    
    public func play() {
        do {
            try engine.start()
        } catch {
            print("error couldn't start engine")
            print("\(error)")
        }
        
        DispatchQueue.once(token: "midiPlayer") {
            configureSampler()
        }
        
        do {
            try playSequencer(sequencer)
        } catch {
            print("cannot start sequencer")
            print("\(error)")
        }
    }
    
    private func playSequencer(_ sequencer: AVAudioSequencer) throws {
        if sequencer.isPlaying {
            sequencer.stop()
        }
        
        sequencer.currentPositionInBeats = TimeInterval(0)
        sequencer.prepareToPlay()
        
        try sequencer.start()
    }
    
    public func setVolume(_ volume: Float, forTrack trackIndex: Int) {
        guard trackIndex < tracksAndSamplers.count else {
            return
        }

        // Trying to set the volume this way causes weird things to be printed. The busses don't match up right.
        let mixer = engine.mainMixerNode
        if let sampler = tracksAndSamplers[trackIndex].1,
            let connection = engine.outputConnectionPoints(for: sampler, outputBus: 0).first,
            let node = connection.node,
            let mixingDestination = sampler.destination(forMixer: node, bus: connection.bus) {
            print("Setting volume for track \(trackIndex) on bus \(mixingDestination.connectionPoint.bus) to \(volume)")
            mixingDestination.volume = volume
        }
        
//        sampler.volume = volume
    }
}
