//
//  ViewController.swift
//  MyFirstAudio
//
//  Created by Niklas Kramer on 14.06.20.
//  Copyright © 2020 Niklas Kramer. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI



class ViewController: UIViewController {
    
    //Design
    var mainColor = UIColor.systemGreen
    var backGroundColor = UIColor.white
    
    //HapticEngine
    let hapticEngine = UIImpactFeedbackGenerator(style: .light)
    
    //Music Stuff
    var kickPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var snarePattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var clapPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var hihatPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var openhihatPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var tomPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var shakerPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var rimShotPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    var currentPattern = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var currentInstrument = Sequence.kickDrum
    var bpm:Double = 120
    var started = false
    
    var instrumentPatterns = [[Int]()]
    let conductor = Conductor()
    
    var currentStep: Double = 0 {
        didSet {
            if currentStep != oldValue{
                updateStepProgress()
            }
            
        }
    }
    
    @IBOutlet var instruments: [UIButton]!
    @IBOutlet var sequencerSteps: [UIButton]!
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var reverbSlider: UISlider!
    @IBOutlet weak var tempoSlider: AKSlider!
    @IBOutlet weak var startStop: UIButton!
    @IBOutlet weak var stepProgressBar: UIProgressView!
    @IBOutlet weak var reverbLabel: UILabel!
    @IBOutlet weak var helpButton: UIButton!
    
    
    @IBAction func setReverbAmount(_ sender: UISlider) {
        conductor.setReverb(value: Double(sender.value))
    }
    @IBAction func Tempo(_ sender: UISlider) {
        // set BPM between 40 .. 160
        bpm = round((sender.value)*160 + 40)
        bpmLabel.text = String(format:"%.1f",(bpm))
        conductor.setSequencerTempo(bpm: Double(bpm))
    }
    
    @IBAction func activateStep(_ sender: UIButton) {
        hapticEngine.impactOccurred()
        let buttonTag = sender.tag
        
        if currentPattern[buttonTag] != 0 {
            currentPattern[buttonTag] = 0
            sender.backgroundColor = UIColor.white
        }
        else{
            currentPattern[buttonTag] = 1
            sender.backgroundColor = mainColor
        }
 
        updateStepsInUI(var: currentPattern)
        
        if currentInstrument == Sequence.kickDrum{
            kickPattern = currentPattern
            conductor.updateKickDrumPattern(var: kickPattern)
        }
        if currentInstrument == Sequence.snareDrum{
            snarePattern = currentPattern
            conductor.updateSnareDrumPattern(var: snarePattern)
        }
        if currentInstrument == Sequence.hihat{
            hihatPattern = currentPattern
            conductor.updateHihattPattern(var: hihatPattern)
        }
        if currentInstrument == Sequence.openhihat{
            openhihatPattern = currentPattern
            conductor.updateOpenHihatPattern(var: openhihatPattern)
        }
        if currentInstrument == Sequence.rimshot{
            rimShotPattern = currentPattern
            conductor.updateRimshotPattern(var: rimShotPattern)
        }
        if currentInstrument == Sequence.clap{
            clapPattern = currentPattern
            conductor.updateClapPattern(var: clapPattern)
        }
        if currentInstrument == Sequence.shaker{
            shakerPattern = currentPattern
            conductor.updateShakerPattern(var: shakerPattern)
        }
        if currentInstrument == Sequence.tom{
            tomPattern = currentPattern
            conductor.updateTomPattern(var: tomPattern)
        }
        
       updatePatterns()
        
    }
    
    @IBAction func selectInstrument(_ sender: UIButton) {
        currentInstrument = Sequence(rawValue: sender.tag)!
        currentPattern =  instrumentPatterns[sender.tag]
        updateStepsInUI(var: instrumentPatterns[sender.tag])
        highlightInstrumentUI(selectedInstrument: sender.tag)
    }
    
    @IBAction func startStopSequencer(_ sender: Any) {
        conductor.startStopSequencer()
        getCurrentSequencerPosition()
        
        if !started {
            started = true
            startStop.setTitle("STOP", for: [])
            startStop.backgroundColor = mainColor
            startStop.setTitleColor(backGroundColor, for: [])
        }
        else{
            started = false
            startStop.setTitle("START", for: [])
            startStop.backgroundColor = backGroundColor
           startStop.setTitleColor(mainColor, for: [])


        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        conductor.setupSequencerTracks()
    }
    
    func setupUI(){
        updatePatterns()
        updateStepsInUI(var: currentPattern)
        bpmLabel.text = String(format:"%.1f",(bpm))
        startStop.setTitle("START", for: [])
        highlightInstrumentUI(selectedInstrument: 0)
        stepProgressBar.progress = 0.0
        
        
        //STYLING
        for sequencerStep in sequencerSteps{
            sequencerStep.layer.borderWidth = 1
            sequencerStep.layer.borderColor = mainColor.cgColor
        }
        
        for instrumentButton in instruments{
            instrumentButton.layer.borderWidth = 1.5
            instrumentButton.layer.borderColor = mainColor.cgColor
            instrumentButton.backgroundColor = backGroundColor
            instrumentButton.setTitleColor(mainColor, for: [])
        }
        
        // Highlight Kick
        highlightInstrumentUI(selectedInstrument: 0)
        
        // Style startStop Button
        startStop.layer.borderWidth = 1.5
        startStop.layer.borderColor = mainColor.cgColor
        startStop.backgroundColor = backGroundColor
        startStop.setTitleColor(mainColor, for: [])
        
        reverbSlider.tintColor = mainColor
        tempoSlider.tintColor = mainColor
        stepProgressBar.tintColor = mainColor
        stepProgressBar.backgroundColor = backGroundColor
        bpmLabel.textColor = mainColor
        reverbLabel.textColor = mainColor
        helpButton.setTitleColor(mainColor, for: [])
        
        

    }
    
    func updateStepsInUI(`var` pattern: [Int]){
        for index in 0...pattern.count-1 {
            if pattern[index] != 0 {
                sequencerSteps[index].backgroundColor = mainColor
            }
            else {
                sequencerSteps[index].backgroundColor = backGroundColor
            }
        }
        updatePatterns()
    }
   
    
    func highlightInstrumentUI(selectedInstrument: Int) {
        
        for instrument in instruments{
            if instrument.tag as AnyObject === selectedInstrument as AnyObject{
                instrument.backgroundColor = mainColor
                instrument.setTitleColor(backGroundColor, for: [])
            }
            else{
                instrument.backgroundColor = backGroundColor
                instrument.setTitleColor(mainColor, for: [])
            }
        }
    }
    

    func getCurrentSequencerPosition() {
        DispatchQueue.global(qos: .background).async {
            while(self.started){
                self.currentStep = self.conductor.getCurrentStep()
            }
        }
    }
    
    func updateStepProgress(){
        DispatchQueue.main.async {
            self.stepProgressBar.setProgress(Float(self.currentStep/16), animated: false)
        }
    }
    
    func updatePatterns(){
        instrumentPatterns = [kickPattern, snarePattern,hihatPattern, clapPattern,rimShotPattern,openhihatPattern,tomPattern,shakerPattern]
    }
   
}

