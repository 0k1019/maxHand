//
//  HandClassification.swift
//  MaxHand
//
//  Created by 권영호 on 24/03/2019.
//  Copyright © 2019 0ho_kwon. All rights reserved.
//


import CoreML
import Vision


public class HandClassification {
    let visionQueue = DispatchQueue(label: "com.youngho.handclassification")
    private lazy var predictionRequest: VNCoreMLRequest = {
        do{
            let model = try VNCoreMLModel(for: handClassification().model)
            let request = VNCoreMLRequest(model: model )
            request.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
            return request
        } catch {
            fatalError("can't load Vision ML Model: \(error)")
        }
    }()
    func perfomrClassification(inputBuffer: CVPixelBuffer, completion: @escaping(_ outputString: String?, _ error: Error?) -> Void) {
//        let deviceOrientation = UIDevice.current.orientation.getImagePropertyOrientation()

        let requestHandler = VNImageRequestHandler(cvPixelBuffer: inputBuffer, orientation: .right, options: [:])
        visionQueue.async {
            do{
                try requestHandler.perform([self.predictionRequest])
                guard let observations = self.predictionRequest.results else{
                    return
                }
                let classifications = observations[0...2].compactMap({$0 as? VNClassificationObservation})
                    .map({"\($0.identifier) \(String(format:" : %.2f", $0.confidence))"})
                    .joined(separator: "\n")
                let topPrediction =  classifications.components(separatedBy: "\n")[0]
                let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
                completion(topPredictionName,nil)
                
            } catch {
                completion(nil, error)
            }
        }
    }
}
