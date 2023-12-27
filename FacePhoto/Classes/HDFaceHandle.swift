//
//  HDFaceHandle.swift
//  FacePhoto
//
//  Created by chaojie zheng on 2023/2/15.
//

import UIKit
import AVFoundation

public class HDFaceHandle: NSObject {
    private var completeClosure: ((Bool, Error?) -> Void)?
    private var resultClosure: (([HDAssertInfo]) -> Void)?
    
    private var curPhotosHadFace: Bool = false
    
    private var curCheckNumber: Int = 0
    private var totalCount: Int = 0

    public lazy var cacheDict: [String: Bool] = {
        let dict = HDAlbumCacheDict.value ?? [:]
        return dict
    }()
    
    lazy var dispatchQueue: OperationQueue = {
        let v = OperationQueue()
        v.maxConcurrentOperationCount = 6
        return v
    }()
    
    public func cancelOpetions() {
        dispatchQueue.cancelAllOperations()
    }
    
    public func check(items: [HDAssertInfo], result: @escaping ([HDAssertInfo]) -> Void, complete: @escaping (_ hadFace: Bool, Error?) -> Void) {
        guard items.count > 0 else {
            complete(false, nil)
            return
        }
        
        resultClosure = result
        completeClosure = complete
        curCheckNumber = 0
        curPhotosHadFace = false
        totalCount = items.count
        
        DispatchQueue.global().async { [weak self] in
            self?.realCheck(items, result: result, complete: complete)
        }
    }
    
    func realCheck(_ items: [HDAssertInfo], result: @escaping ([HDAssertInfo]) -> Void, complete: @escaping (_ hadFace: Bool, Error?) -> Void) {
        var options = [HDImageFaceCheckOperation]()
        
        var cachedAr = [HDAssertInfo]()
        
        items.forEach { [weak self] model in
            guard let `self` = self else { return }
            
            if let hasFace = self.cacheDict[model.localIdentifier] {
                self.curCheckNumber += 1
                if hasFace {
                    cachedAr.append(model)
                }
                model.haveFace = hasFace
                safeMainThreadClosure {
                    result([model])
                }
            } else {
                let op = HDImageFaceCheckOperation()
                op.assertInfo = model
                op.completionBlock = { [weak self, op] in
                    guard op.isCancelled == false else { return }
                    guard let `self` = self else { return }
                    self.checkComplete(model: op.assertInfo, count: self.totalCount, haveFace: op.faceCount > 0)
                }
                options.append(op)
            }
        }
        
        if options.count > 0 {// 有未检测的图片
            self.dispatchQueue.addOperations(options, waitUntilFinished: false)
        } else {// 没有未检测的图片，全部为缓存
            curPhotosHadFace = cachedAr.count > 0
            
            safeMainThreadClosure { [weak self] in
                guard let `self` = self else { return }
                
                complete(self.curPhotosHadFace, nil)
            }
        }
        
    }
    
    func checkComplete(model: HDAssertInfo?, count: Int, haveFace: Bool) {
        guard let model = model else {
            return
        }
        
        safeMainThreadClosure { [weak self] in
            guard let `self` = self else { return }
            
            // 更新缓存
            self.cacheDict[model.localIdentifier] = haveFace
            HDAlbumCacheDict.value = self.cacheDict
            
            if haveFace {
                self.curPhotosHadFace = true
                model.haveFace = true
            }
            
            self.resultClosure?([model])
            
            self.curCheckNumber += 1
            
            if self.curCheckNumber % count == 0 {// 完成处理
                self.completeClosure?(self.curPhotosHadFace, nil)
            }
        }
    }
}
