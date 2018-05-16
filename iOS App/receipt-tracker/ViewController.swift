//
//  ViewController.swift
//  receipt-tracker
//
//  Created by Harshil Parikh on 2018-02-03.
//  Copyright © 2018 QHacks 2018. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import NVActivityIndicatorView

class ViewController: UIViewController, UIGestureRecognizerDelegate, AVCapturePhotoCaptureDelegate,  NVActivityIndicatorViewable {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?

    @IBOutlet weak var shutter: UIButton!
    @IBOutlet weak var previewLayer: UIView!
    
    var blurEffect: UIBlurEffect?
    var blurEffectView: UIVisualEffectView?
    
    var capturedImage : UIImage?
    
    var items : [String : Any] = [:]
    var total : NSNumber = 0
    var type : String = ""
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func pinchZoom(_ sender: Any) {
        (sender as! UIPinchGestureRecognizer).delegate = self
        var vZoomFactor = ((sender as! UIPinchGestureRecognizer).scale)
        setZoom(zoomFactor: vZoomFactor, velocity: (sender as AnyObject).velocity)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.tag = 100
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            capturePhotoOutput = AVCapturePhotoOutput()
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            capturePhotoOutput?.isHighResolutionCaptureEnabled = false
            // Set the output on the capture session
            captureSession?.addOutput(capturePhotoOutput!)
        
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            previewLayer.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.commitConfiguration()
            captureSession?.startRunning()
        } catch {
            print(error)
        }
        
        self.previewLayer.bringSubview(toFront: shutter)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setZoom(zoomFactor:CGFloat, velocity:CGFloat) {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        var error:NSError!
        do{
            try device?.lockForConfiguration()
            defer {device?.unlockForConfiguration()}
            if (zoomFactor <= (device?.activeFormat.videoMaxZoomFactor)!) {
                
                let desiredZoomFactor:CGFloat = zoomFactor + atan2(velocity, 5.0);
                device?.videoZoomFactor = max(1.0, min(desiredZoomFactor, (device?.activeFormat.videoMaxZoomFactor)!));
            }
            else {
                print("Unable to set videoZoom: (max %f, asked %f)", device?.activeFormat.videoMaxZoomFactor, zoomFactor);
            }
        }
        catch error as NSError{
            NSLog("Unable to set videoZoom: %@", error.localizedDescription);
        }
        catch _{
        }
    }
    
    @IBAction func shutterClicked(_ sender: Any) {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = false
        photoSettings.flashMode = .auto
        // Call capturePhoto method by passing our photo settings and a
        // delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                 resolvedSettings: AVCaptureResolvedPhotoSettings,
                 bracketSettings: AVCaptureBracketedStillImageSettings?,
                 error: Error?) {
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return
        }
        // Convert photo same buffer to a jpeg image data by using // AVCapturePhotoOutput
        guard let imageData =
            AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
                return
        }
        // Initialise a UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            // Save our captured image to photos album
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            NVActivityIndicatorView.DEFAULT_TYPE = .pacman
            let activityData = ActivityData()
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
            
            //only apply the blur if the user hasn't disabled transparency effects
            if !UIAccessibilityIsReduceTransparencyEnabled() {
                view.backgroundColor = .clear
                
                //always fill the view
                blurEffectView?.frame = self.view.bounds
                blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                view.addSubview(self.blurEffectView!) //if you have more UIViews, use an insertSubview API to place it where needed
            } else {
                view.backgroundColor = .black
            }
            self.previewLayer.bringSubview(toFront: blurEffectView!)
            postToImgur(image: image, for: "harparrr")
        }
    }
    
    func postToOurAPI(id: String) {
        let urlString = "https://jli0423.lib.id/image-api@dev/image/"
        
        let parameters: Parameters = [
            "imgurID" : id
        ]
        
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON() {
            response in
            print(response.request)
            switch response.result {
                case .success:
                    print(response)
                    //This is what you have been missing
                    let json = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                    self.items = (json?["items"] as? [String:Any])!
                    self.total = (json?["total"] as? NSNumber)!
                    self.type = (json?["type"] as? String)!
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    DispatchQueue.main.async {
                        self.blurEffectView?.removeFromSuperview()
                        self.previewLayer.willRemoveSubview(self.blurEffectView!)
                        for subview in self.previewLayer.subviews
                        {
                            print("subview of previewLayer ", subview)
                        }
                        for subview in (self.previewLayer?.subviews)! {
                            if subview is UIVisualEffectView {
                                subview.removeFromSuperview()
                            }
                        }
                        self.performSegue(withIdentifier: "Items", sender: nil)
                    }
                    break
                case .failure(let error):
                    
                    print(error)
                }
        }
    }
    
    func postToImgur(image: UIImage, for username: String) {
        print("post function")
        let imageData = UIImagePNGRepresentation(image)
        let base64Image = imageData?.base64EncodedString(options: .lineLength64Characters)
        
        let url = "https://api.imgur.com/3/upload"
        
        let parameters = [
            "image": base64Image
        ]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let imageData = UIImagePNGRepresentation(image) {
                multipartFormData.append(imageData, withName: username, fileName: "\(username).png", mimeType: "image/png")
            }
            
            var imgData = NSData(data: UIImagePNGRepresentation(image)!)
            print("we got image data ", Double(imgData.length)/1024.0)
            
            for (key, value) in parameters {
                multipartFormData.append((value?.data(using: .utf8))!, withName: key)
            }}, to: url, method: .post, headers: ["Authorization": "Client-ID " + "022b6a89b88e3e3"],
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        print("success")
                        upload.response { response in
                            print("upload.response")
                            //This is what you have been missing
                            let json = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                            print(json)
                            let imageDic = json?["data"] as? [String:Any]
                            print(imageDic?["link"])
                            
                            self.postToOurAPI(id: imageDic?["id"] as! String)
                        }
                    case .failure(let encodingError):
                        print("error:\(encodingError)")
                    }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Items") {
            let resultController = segue.destination as! Items
            print("SELF.ITEMS ", self.items)
            resultController.items = self.items
            resultController.total = self.total
            resultController.type = self.type
        }
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

