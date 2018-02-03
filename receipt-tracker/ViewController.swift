//
//  ViewController.swift
//  receipt-tracker
//
//  Created by Harshil Parikh on 2018-02-03.
//  Copyright © 2018 QHacks 2018. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var requests = [VNRequest]()

    @IBOutlet weak var shutter: UIButton!
    @IBOutlet weak var previewLayer: UIView!
    
    @IBAction func shutterClicked(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        
        self.previewLayer.bringSubview(toFront: shutter)
        
        let rectangleDetectionRequest = VNDetectRectanglesRequest(completionHandler: handleRectangles)
        rectangleDetectionRequest.minimumSize = 0.1
        rectangleDetectionRequest.maximumObservations = 1
        
        self.requests = [rectangleDetectionRequest]

    }
    
    func handleRectangles(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            self.drawVisionRequestResults(request.results as! [VNRectangleObservation])
        }
    }
    
    func drawVisionRequestResults (_ results: [VNRectangleObservation]) {
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.previewLayer.frame.height)
        
        let translate = CGAffineTransform.identity.scaledBy(x: self.previewLayer.frame.width, y: self.previewLayer.frame.height)
        
        for rectangle in results {
            let rectangleBounds = rectangle.boundingBox.applying(translate).applying(transform)
            previewLayer.draw(rectangleBounds)
            
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

