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
}
