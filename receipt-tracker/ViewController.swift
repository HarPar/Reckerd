//
//  ViewController.swift
//  receipt-tracker
//
//  Created by Harshil Parikh on 2018-02-03.
//  Copyright © 2018 QHacks 2018. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var bottom, side, top : Bool?
    var timer : Timer?

    @IBOutlet weak var previewLayer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        bottom = false
        top = false
        side = false
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            previewLayer.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
        } catch {
            print(error)
        }
        
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        previewLayer.addGestureRecognizer(longGesture)
        
    }
    
    @objc func longTap(_ sender: UIGestureRecognizer){
        print("Long tap")
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
            timer?.invalidate()
            timer = nil
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        }
    }
    
    func longPressed(sender: UILongPressGestureRecognizer)
    {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    @objc func update () {
        if (!top!) {
            top = true
            previewLayer.addTopBorderWithColor(color: UIColor.red, width: 5.0)
        } else if (!side!) {
            side = true
            previewLayer.addRightBorderWithColor(color: UIColor.red, width: 5.0)
            previewLayer.addLeftBorderWithColor(color: UIColor.red, width: 5.0)
        } else if (!bottom!) {
            bottom = true
            previewLayer.addBottomBorderWithColor(color: UIColor.red, width: 5.0)
        } else {
            top = false
            side = false
            bottom = false
            previewLayer.addBottomBorderWithColor(color: UIColor.clear, width: 0.0)
            previewLayer.addTopBorderWithColor(color: UIColor.clear, width: 0.0)
            previewLayer.addLeftBorderWithColor(color: UIColor.clear, width: 0.0)
            previewLayer.addRightBorderWithColor(color: UIColor.clear, width: 0.0)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UIView {
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

