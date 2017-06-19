//
//  ViewController.swift
//  MorseTorch
//
//  Created by Jiang, Charlie (AU - Melbourne) on 15/6/17.
//  Copyright © 2017 Charlie's. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sosButton: UIButton!
    @IBOutlet weak var morseText: UITextField!
    @IBOutlet weak var morseCodeTextView: UITextView!
    @IBAction func buttonPress(_ sender: Any) {
        toggleFlash()
    }
    @IBOutlet weak var testButton: UIButton!
    var torchDevice:AVCaptureDevice!
    override func viewDidLoad() {
        super.viewDidLoad()
        torchDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sosFlash(_ sender: Any) {
        start()
        
    }
    func toggleFlash() {
        if (torchDevice.hasTorch) {
            do {
                try torchDevice.lockForConfiguration()
                if (torchDevice.torchMode == AVCaptureTorchMode.on) {
                    torchDevice.torchMode = AVCaptureTorchMode.off
                } else {
                    do {
                        try torchDevice.setTorchModeOnWithLevel(1.0)
                    } catch {
                        print(error)
                    }
                }
                torchDevice.unlockForConfiguration()
            } catch {
                print(error)
            }
            
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func dashFlash(){
        let delay = Int(1 * Double(1000))
        
        flash(flashSeconds: DispatchTime.now() + .milliseconds(delay))
        
    }
    func dotFlash(){
        let delay = Int(0.3 * Double(1000))
        
        flash(flashSeconds: DispatchTime.now() + .milliseconds(delay))    }
    func flash( flashSeconds:DispatchTime){
        do {
            try torchDevice.lockForConfiguration()
            torchDevice.torchMode = AVCaptureTorchMode.on
            DispatchQueue.main.asyncAfter(deadline: flashSeconds) {
                // Your code with delay
                do {
                    try self.torchDevice.lockForConfiguration()
                    self.torchDevice.torchMode = AVCaptureTorchMode.off
                } catch {
                    print(error)
                }
                let sleep = DispatchTime.now() + .milliseconds(Int(1 * Double(1000)))
                
                DispatchQueue.main.asyncAfter(deadline:sleep) {}
            }
            torchDevice.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    /// Short signal duration (LED on)
    private static let shortInterval = 0.2
    /// Long signal duration (LED on)
    private static let longInterval = 0.4
    /// Pause between signals (LED off)
    private static let pauseInterval = 0.2
    /// Pause between the whole SOS sequences (LED off)
    private static let sequencePauseInterval = 2.0
    
    /**
     When the SOS sequence is started flashlight is on. Thus
     the first time interval is for the short signal. Then pause,
     then short, ...
     
     See `timerTick()`, it alternates flashlight status (on/off) based
     on the current index in this sequence.
     */
    private let sequenceIntervals = [
        shortInterval, pauseInterval, shortInterval, pauseInterval, shortInterval, pauseInterval,
        longInterval, pauseInterval, longInterval, pauseInterval, longInterval, pauseInterval,
        shortInterval, pauseInterval, shortInterval, pauseInterval, shortInterval, sequencePauseInterval
    ]
    
    /// Current index in the SOS `sequence`
    private var index: Int = 0
    
    /// Non repeatable timer, because time interval varies
    private weak var timer: Timer?
    
    /**
     Put your `Flashlight()` calls inside this function.
     
     - parameter on: pass `true` to turn it on or `false` to turn it off
     */
    private func turnFlashlight(on: Bool) {
        
        if (torchDevice.hasTorch) {
            do {
                try torchDevice.lockForConfiguration()
                if (on == true){
                    torchDevice.torchMode = AVCaptureTorchMode.on
                }else{
                    torchDevice.torchMode = AVCaptureTorchMode.off
                    
                }
                torchDevice.unlockForConfiguration()
            } catch {
                print(error)
            }
            
        }
    }
    
    private func scheduleTimer() {
        timer = Timer.scheduledTimer(timeInterval: sequenceIntervals[index], target: self, selector: #selector(ViewController.timerTick), userInfo: nil, repeats: false)
    }
    
    @objc private func timerTick() {
        index = index + 1
        // Increase sequence index, at the end?
        if index == sequenceIntervals.count {
            // Start from the beginning
            index = 0
        }
        // Alternate flashlight status based on current index
        // index % 2 == 0 -> is index even number? 0, 2, 4, 6, ...
        turnFlashlight(on: index % 2 == 0)
        scheduleTimer()
    }
    
    func start() {
        index = 0
        turnFlashlight(on: true)
        scheduleTimer()
    }
    
    func stop() {
        timer?.invalidate()
        turnFlashlight(on: false)
    }
    
    deinit {
        timer?.invalidate()
    }
}

