//
//  File.swift
//  MaxHand
//
//  Created by 권영호 on 10/03/2019.
//  Copyright © 2019 0ho_kwon. All rights reserved.
//

import CoreML
import Vision

public class HandDetector {
    let visionQueue = DispatchQueue(label:"com.youngho.maxhand")
    private lazy var predictionRequest: VNCoreMLRequest = {
        do{
            let model = try VNCoreMLModel(for: HandModel().model)
            let request = VNCoreMLRequest(model: model)
            request.imageCropAndScaleOption = VNImageCropAndScaleOption.scaleFill
            return request
        } catch {
            fatalError("can't load Vision ML Model: \(error)")
        }
    }()
    
    func performDetection(inputBuffer: CVPixelBuffer, completion: @escaping(_ outputBuffer: CVPixelBuffer?, _ error: Error?) -> Void) {
        // Right orientation because the pixel data for image captured by an iOS device is encoded in the camera sensor's native landscape orientation
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: inputBuffer, orientation: .right)
        //비동기처리가 필요하다.
        visionQueue.async{
            do {
                try requestHandler.perform([self.predictionRequest])
                guard let observation = self.predictionRequest.results?.first as? VNPixelBufferObservation else {
                    fatalError("Unexpected result type from VNCoreMLRequest")
                }
                //observation.pixelBuffer가 원래 결과 이미지다.
                completion(observation.pixelBuffer, nil)
            } catch {
                completion(nil, error)
            }
            
        }
    }
    
}
