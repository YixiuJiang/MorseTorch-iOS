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
        dotFlash()
        dotFlash()
        dotFlash()
        dashFlash()
        dashFlash()
        
        dashFlash()
        dotFlash()
        dotFlash()
        dotFlash()
        
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
}

