//
//  Conductor.swift
//  MyFirstAudio
//
//  Created by Niklas Kramer on 27.06.20.
//  Copyright © 2020 Niklas Kramer. All rights reserved.
//

import Foundation
import AudioKit

class Conductor {
    
    //PATTERNS
    var kickPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var snarePattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var clapPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var hihatPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var openhihatPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var tomPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var shakerPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var rimShotPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    //SEQUENCER
    var sequencerStarted = false
    var sequencer = AKAppleSequencer()
    let sequenceLength = AKDuration(beats: 16)
    
    // SOUND SOURCES
    var kick = AKMIDISampler()
    var snare = AKMIDISampler()
    var clap = AKMIDISampler()
    var hihat = AKMIDISampler()
    var openhihat = AKMIDISampler()
    var tom = AKMIDISampler()
    var shaker = AKMIDISampler()
    var rimshot = AKMIDISampler()
    var activeStepPositionInt = 0
    
    //EFFECTS AND MORE
    var verb: AKReverb2!
    var compressor: AKCompressor!
    var mixer: AKMixer!

    
    
    init(){
        
        // Panning
        let hihatPanner = AKPanner(hihat)
        hihatPanner.pan = 0.7
        let openHihatPanner = AKPanner(openhihat)
        openHihatPanner.pan = 0.6
        let shakerPanner = AKPanner(shaker)
        shakerPanner.pan = -0.7
        
        
        //Mixing
        let drumMixer = AKMixer(kick,snare,clap,hihatPanner,openHihatPanner,tom,shakerPanner,rimshot)
        compressor = AKCompressor(drumMixer)
        verb = AKReverb2(compressor)

        mixer = AKMixer(verb)
        AudioKit.output = mixer
        
        //Compressor Setting
        compressor.threshold = -1
        compressor.dryWetMix = 0.1
        compressor.attackDuration = 0.15
        
        //: loading samples
        try! kick.loadWav("./Samples/BD")
        try! snare.loadWav("./Samples/SD")
        try! hihat.loadWav("./Samples/HIHAT")
        try! openhihat.loadWav("./Samples/OPENHIHAT")
        try! tom.loadWav("./Samples/TOM")
        try! rimshot.loadWav("./Samples/RIMSHOT")
        try! shaker.loadWav("./Samples/SHAKER")
        try! clap.loadWav("./Samples/CLAP")
        
        sequencer.setTempo(240)
        verb.dryWetMix = 0.5
        
        // start Audiokit
        do {
            try AudioKit.start()
        }
        catch {
            AKLog("AudioKit did not start!")
        }
    }
    
    func startStopSequencer(){
        sequencerStarted ? sequencer.stop() : sequencer.play()
        sequencerStarted = (sequencerStarted) ? false : true
        sequencerStarted ? sequencer.rewind() : ()
    }
    
    func setupSequencerTracks() {
        _ = sequencer.newTrack()
        sequencer.setLength(sequenceLength)
        sequencer.tracks[Sequence.kickDrum.rawValue].setMIDIOutput(kick.midiIn)
        getKickDrumPattern()
        
        _ = sequencer.newTrack()
        sequencer.tracks[Sequence.snareDrum.rawValue].setMIDIOutput(snare.midiIn)
        getSnareDrumPattern()
        
        _ = sequencer.newTrack()
        sequencer.tracks[Sequence.hihat.rawValue].setMIDIOutput(hihat.midiIn)
        getHihatPattern()
        
        _ = sequencer.newTrack()
        sequencer.tracks[Sequence.clap.rawValue].setMIDIOutput(clap.midiIn)
        getClapPattern()
        
        _ = sequencer.newTrack()
        sequencer.tracks[Sequence.rimshot.rawValue].setMIDIOutput(rimshot.midiIn)
        getRimShotPattern()
        
        _ = sequencer.newTrack()
        sequencer.tracks[Sequence.openhihat.rawValue].setMIDIOutput(openhihat.midiIn)
        getOpenHihatPattern()
        
        _ = sequencer.newTrack()
        sequencer.tracks[Sequence.tom.rawValue].setMIDIOutput(tom.midiIn)
        getTomPattern()
        
        _ = sequencer.newTrack()
        sequencer.tracks[Sequence.shaker.rawValue].setMIDIOutput(shaker.midiIn)
        getShakerPattern()
        
        sequencer.enableLooping()
    }
    
    func setSequencerTempo(bpm: Double){
        sequencer.setTempo(2*bpm) // still need to figure out why tempo has to be doubled
    }
    
    func getCurrentStep() -> Double {
        let position = Double(round(sequencer.currentRelativePosition.beats))
        return position
    }
    
    // --------------------------------------------------------------------------- //
    // --------------------------------------------------------------------------- //
    
    func getKickDrumPattern(){
        sequencer.tracks[Sequence.kickDrum.rawValue].clear()
        let numberOfSteps = kickPattern.count
        for i in 0 ..< numberOfSteps {
            if kickPattern[i] != 0 {
                let step = Double(i)
                sequencer.tracks[Sequence.kickDrum.rawValue].add(noteNumber: 60,
                                                                 velocity: 90,
                                                                 position: AKDuration(beats: step),
                                                                 duration: AKDuration(beats: 1))
            }
        }
    }
    
    func updateKickDrumPattern(`var` updatedKickPattern: [Int]){
        kickPattern = updatedKickPattern
        getKickDrumPattern()
        
    }
    
    func getSnareDrumPattern(){
        sequencer.tracks[Sequence.snareDrum.rawValue].clear()
        let numberOfSteps = snarePattern.count
        for i in 0 ..< numberOfSteps {
            if snarePattern[i] != 0 {
                let step = Double(i)
                sequencer.tracks[Sequence.snareDrum.rawValue].add(noteNumber: 60,
                                                                  velocity: 100,
                                                                  position: AKDuration(beats: step),
                                                                  duration: AKDuration(beats: 1))
            }
        }
    }
    
    func updateSnareDrumPattern(`var` updatedSnarePattern: [Int]){
        snarePattern = updatedSnarePattern
        getSnareDrumPattern()
    }
    
    func getHihatPattern(){
        sequencer.tracks[Sequence.hihat.rawValue].clear()
        
        let numberOfSteps = hihatPattern.count
        for i in 0 ..< numberOfSteps {
            if hihatPattern[i] != 0 {
                let step = Double(i)
                sequencer.tracks[Sequence.hihat.rawValue].add(noteNumber: 60,
                                                              //randomising velocity to make the pattern sound more lively
                                                              velocity: MIDINoteNumber((Int.random(in: 50..<80))),
                                                              position: AKDuration(beats: step),
                                                              duration: AKDuration(beats: 1))
            }
        }
    }
    
    func updateHihattPattern(`var` updatedHihatPattern: [Int]){
        hihatPattern = updatedHihatPattern
        getHihatPattern()
    }
    
    func getClapPattern(){
        sequencer.tracks[Sequence.clap.rawValue].clear()
        
        let numberOfSteps = clapPattern.count
        for i in 0 ..< numberOfSteps {
            if clapPattern[i] != 0 {
                let step = Double(i)
                sequencer.tracks[Sequence.clap.rawValue].add(noteNumber: 60,
                                                             velocity: 70,
                                                             position: AKDuration(beats: step),
                                                             duration: AKDuration(beats: 1))
            }
        }
    }
    
    func updateClapPattern(`var` updatedClapPattern: [Int]){
        clapPattern = updatedClapPattern
        getClapPattern()
    }
    
    func getRimShotPattern(){
        sequencer.tracks[Sequence.rimshot.rawValue].clear()
        
        let numberOfSteps = rimShotPattern.count
        for i in 0 ..< numberOfSteps {
            if rimShotPattern[i] != 0 {
                let step = Double(i)
                sequencer.tracks[Sequence.rimshot.rawValue].add(noteNumber: 60,
                                                                velocity: 80,
                                                                position: AKDuration(beats: step),
                                                                duration: AKDuration(beats: 1))
            }
        }
    }
    
    func updateRimshotPattern(`var` updatedRimshotPattern: [Int]){
        rimShotPattern = updatedRimshotPattern
        getRimShotPattern()
    }
    
    func getOpenHihatPattern(){
        sequencer.tracks[Sequence.openhihat.rawValue].clear()
        
        let numberOfSteps = openhihatPattern.count
        for i in 0 ..< numberOfSteps {
            if openhihatPattern[i] != 0 {
                let step = Double(i)
                sequencer.tracks[Sequence.openhihat.rawValue].add(noteNumber:60,
                                                                  velocity: MIDINoteNumber((Int.random(in: 30..<45))),
                                                                  position: AKDuration(beats: step),
                                                                  duration: AKDuration(beats: 1))
            }
        }
    }
    
    func updateOpenHihatPattern(`var` updatedOpenHihatPattern: [Int]){
        openhihatPattern = updatedOpenHihatPattern
        getOpenHihatPattern()
    }
    
    func getTomPattern(){
        sequencer.tracks[Sequence.tom.rawValue].clear()
        let numberOfSteps = tomPattern.count
        for i in 0 ..< numberOfSteps {
            if tomPattern[i] != 0 {
                let step = Double(i)
                sequencer.tracks[Sequence.tom.rawValue].add(noteNumber: MIDINoteNumber((Int.random(in: 58..<62))),
                                                            velocity: 80,
                                                            position: AKDuration(beats: step),
                                                            duration: AKDuration(beats: 1))
            }
        }
    }
    
    func updateTomPattern(`var` updatedTomPattern: [Int]){
        tomPattern = updatedTomPattern
        getTomPattern()
    }
    
    func getShakerPattern(){
        sequencer.tracks[Sequence.shaker.rawValue].clear()
        let numberOfSteps = shakerPattern.count
        for i in 0 ..< numberOfSteps {
            if shakerPattern[i] != 0 {
                let step = Double(i)
                sequencer.tracks[Sequence.shaker.rawValue].add(noteNumber: 60,
                                                               velocity: MIDINoteNumber((Int.random(in: 35..<80))),
                                                               position: AKDuration(beats: step),
                                                               duration: AKDuration(beats: 1))
            }
        }
    }
    
    func updateShakerPattern(`var` updatedShakerPattern: [Int]){
        shakerPattern = updatedShakerPattern
        getShakerPattern()
    }
    
    func setReverb(value: Double){
        verb.dryWetMix = value
    }
    
}
