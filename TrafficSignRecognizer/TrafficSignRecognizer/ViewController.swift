//
//  ViewController.swift
//  TrafficSignRecognizer
//
//  Created by Tomasz Kasperek on 15.09.2018.
//  Copyright © 2018 PUT. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var visionRequests = [VNRequest]()
    var trafficSignModel: TrafficSignModel?
    let captureQueue = DispatchQueue(label: "captureQueue")
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let camera = AVCaptureDevice.default(for: .video)
            let input = try AVCaptureDeviceInput(device: camera!)
            captureSession = AVCaptureSession()
            captureSession!.sessionPreset = .high
            captureSession!.addInput(input)
        } catch {
            fatalError("Couldn't get input from video device")
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer!.frame = previewView.layer.bounds
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: captureQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        captureSession!.addOutput(videoOutput)
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection!.videoOrientation = .portrait
        captureSession!.startRunning()
        
        previewView.layer.addSublayer(videoPreviewLayer!)
        
        // set up the request using our vision model
        do {
            trafficSignModel = try TrafficSignModel()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer!.frame = previewView.bounds
    }
    
    func resizeImage(_ imageBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        let imageWidth = CVPixelBufferGetWidth(imageBuffer)
        let imageHeight = CVPixelBufferGetHeight(imageBuffer)
        
        // For rectangle
        let finalSize = 48
        let cropX = Int(imageWidth / 2 - finalSize / 2)
        let cropY = Int(imageHeight / 2 - finalSize / 2)
        
        return resizePixelBuffer(imageBuffer, cropX: cropX, cropY: cropY, cropWidth: finalSize, cropHeight: finalSize, scaleWidth: 1, scaleHeight: 1)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let visionRequests = self.trafficSignModel?.visionRequests else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let resizedPixelBuffer = resizeImage(pixelBuffer) else { return }
        
        DispatchQueue.main.async {
            let bufferUiImage = UIImage(pixelBuffer: resizedPixelBuffer)
            self.imageView.image = bufferUiImage
        }
        
        
        let deviceOrientation = CGImagePropertyOrientation(rawValue: UInt32(UIDevice.current.orientation.rawValue))!
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: deviceOrientation, options: [:])
        try? imageRequestHandler.perform(visionRequests)
    }
}

