//
//  HDImageFaceCheckOperation.swift
//  FacePhoto
//
//  Created by chaojie zheng on 2023/2/15.
//

import UIKit
 
/// 图片检测是否包含人脸队列
public class HDImageFaceCheckOperation: Operation {
    
    override init() {
        super.init()
    }
    
    public override var isExecuting: Bool {
        get {
            execute
        }
    }
    
    var execute: Bool = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    public override var isFinished: Bool {
        get {
            finish
        }
    }
    
    public override var isAsynchronous: Bool {
        true
    }
    
    var finish: Bool = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    public var assertInfo: HDAssertInfo?
    
    public override var isReady: Bool {
        assertInfo != nil
    }
    
    func done() {
        execute = false
        finish = true
    }
    
    public var faceCount: Int = 0
    
    public override func start() {
        guard let assert = assertInfo?.asset else {
            done()
            return
        }
        
        _ = HDPhotoLibraryManager.fetchImage(for: assert, size: CGSize(width: 180, height: 180), resizeMode: .fast) {[weak self] (tmpImage, _) in
            guard let `self` = self, let img = tmpImage else {
                self?.done()
                return
            }
            
            if self.isCancelled {
                self.done()
                return
            }
            
            DispatchQueue.global().async { [weak self, img] in
                guard let `self` = self else {
                    self?.done()
                    return
                }
                
                if self.isCancelled {
                    self.done()
                    return
                }
                
                let detector = HDFaceDetector()
                detector.detect(image: img) {[weak self] info in
                    guard let `self` = self else {
                        self?.done()
                        return
                    }
                    
                    if self.isCancelled {
                        self.done()
                        return
                    }
                    
                    self.assertInfo?.faceRects = info?.faceRects
                    
                    self.faceCount = info?.faceRects?.count ?? 0
                    
                    self.done()
                }
            }
        }
    }
}
