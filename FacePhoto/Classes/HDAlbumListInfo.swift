//
//  HDAlbumListInfo.swift
//  FacePhoto
//
//  Created by chaojie zheng on 2023/2/15.
//

import UIKit
import Photos

extension HDAlbumListInfo {
    
    static func ==(lhs: HDAlbumListInfo, rhs: HDAlbumListInfo) -> Bool {
        return lhs.title == rhs.title && lhs.count == rhs.count && lhs.headAsset?.localIdentifier == rhs.headAsset?.localIdentifier
    }
}

public class HDAlbumListInfo: NSObject {

    public var result: PHFetchResult<PHAsset>

    public let collection: PHAssetCollection

    public var title: String {
        return collection.localizedTitle ?? ""
    }

    public var headAsset: PHAsset? {
        return result.lastObject
    }

    public var selectStateChange: ((Bool) -> Void)?
    public var isSelect: Bool = false {
        didSet {
            selectStateChange?(isSelect)
        }
    }

    public var headAssetImage: UIImage?
    
    public var count: Int {
        return result.count
    }

    public init(collection: PHAssetCollection, assets: PHFetchResult<PHAsset>) {
        self.collection = collection
        self.result = assets
    }
    
    /// 获取分组封面图
    public func fetchHeadAssetImage(imageSize size: CGSize, _ complete: @escaping (UIImage?) -> Void) {
        if let headAssetImage = headAssetImage {
            complete(headAssetImage)
            return
        }

        if let headAsset = headAsset {
            _ = HDPhotoLibraryManager.fetchImage(for: headAsset, size: size) { image, _ in
                self.headAssetImage = image
                complete(image)
            }
        } else {
            complete(nil)
        }
    }
}
