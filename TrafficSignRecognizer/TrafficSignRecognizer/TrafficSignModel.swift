//
//  TrafficSignModel.swift
//  TrafficSignDetector
//
//  Created by Tomasz Kasperek on 10.09.2018.
//

import Foundation
import AVFoundation
import Vision

class TrafficSignModelInitError: Error {
    var localizedDescription = "Can't initialize model. Check if path is correct"
}

class TrafficSignModel {
    let model: VNCoreMLModel!
    var visionRequests = [VNCoreMLRequest]()
    var onClassificationResult: ((VNClassificationObservation) -> Void)?
    
    init() throws {
        do {
            model = try VNCoreMLModel(for: trafficSignUpdated().model)
            
            let classificationRequest = VNCoreMLRequest(model: model, completionHandler: handleClassifications)
            classificationRequest.imageCropAndScaleOption = .centerCrop
            
            visionRequests = [classificationRequest]
        } catch {
            throw TrafficSignModelInitError()
        }
    }
    
    func handleClassifications(request: VNRequest, error: Error?) {
        if let theError = error {
            print("Error: \(theError)")
            return
        }
        
        guard let results = request.results?.compactMap({ $0 as? VNClassificationObservation }) else {
            print("No results found")
            return
        }
        
        guard let bestResult = results.first else { return }
        self.onClassificationResult?(bestResult)
    }
}
