//
//  HDFaceDetector.swift
//  FacePhoto
//
//  Created by chaojie zheng on 2023/2/15.
//

import UIKit
import Vision
import VisionKit

public class HDFaceDetectResultInfo: NSObject {
    public var faceRects: [CGRect]?
}

/// 图片检测是否包含人脸
public class HDFaceDetector: NSObject {
    
    private var handler: VNImageRequestHandler?
    
    func detect(image: UIImage, completeClosure: @escaping (HDFaceDetectResultInfo?) -> Void) {
        guard let cgImage = CIImage(image: image) else {
            DispatchQueue.main.async {
                completeClosure(nil)
            }
            return
        }
        
        var requestArr: [VNRequest] = []
        
        let faceRequest = VNDetectFaceRectanglesRequest.init { req, err in
            guard err == nil else {
                DispatchQueue.main.async {
                    completeClosure(nil)
                }
                return
            }
            
            let model = HDFaceDetectResultInfo()
            model.faceRects = req.results?.map({ observation in
                guard let faceObj = observation as? VNFaceObservation else {
                    return .zero
                }
                
                return faceObj.boundingBox
            })
            DispatchQueue.main.async {
                completeClosure(model)
            }
        }
        requestArr.append(faceRequest)
        
        handler = VNImageRequestHandler.init(ciImage: cgImage, options: [:])
        
        do {
            try handler?.perform(requestArr)
        } catch {
            print(error.localizedDescription)
        }
    }
}
