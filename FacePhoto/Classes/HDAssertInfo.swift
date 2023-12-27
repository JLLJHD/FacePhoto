//
//  HDAssertInfo.swift
//  FacePhoto
//
//  Created by chaojie zheng on 2023/2/15.
//

import UIKit
import Photos

public class HDAssertInfo: NSObject {
    
    public var asset: PHAsset?

    public var isiCloud: Bool {
        get {
            !HDPhotoLibraryManager.checkAssertIsLocal(asset: asset)
        }
    }

    public var localIdentifier: String {
        get {
            asset?.localIdentifier ?? ""
        }
    }

    public var faceRects: [CGRect]?

    public var haveFace: Bool = false

    public init(_ asset: PHAsset? = nil) {
        super.init()
        self.asset = asset
    }
    
}
