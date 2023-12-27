//
//  HDPhotoLibraryManager.swift
//  FacePhoto
//
//  Created by chaojie zheng on 2023/2/15.
//

import UIKit
import Photos

public class HDPhotoLibraryManager: NSObject {
    
    /// 获取相册组列表
    public class func getPhotoAlbumList(finish: ([HDAlbumListInfo]) -> Void) {
        let option = PHFetchOptions()
        option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        
        let typeMap: [(PHAssetCollectionType, PHAssetCollectionSubtype)] = [
            (.smartAlbum, .albumRegular),
            (.album, .albumRegular),
            (.album, .albumMyPhotoStream),
            (.album, .albumSyncedAlbum),
            (.album, .albumCloudShared)
        ]
        
        var list: [HDAlbumListInfo] = []
        
        typeMap.map({ PHAssetCollection.fetchAssetCollections(with: $0, subtype: $1, options: nil)}).forEach { collections in
            collections.enumerateObjects { assetCollection, _, _ in
                if assetCollection.assetCollectionSubtype == .smartAlbumAllHidden { return }
                if assetCollection.assetCollectionSubtype.rawValue > PHAssetCollectionSubtype.smartAlbumLongExposures.rawValue { return }
                
                let assets = PHAsset.fetchAssets(in: assetCollection, options: option)
                if assets.count == 0 { return }
                
                let listInfo = HDAlbumListInfo(collection: assetCollection, assets: assets)
                
                if assetCollection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    list.insert(listInfo, at: 0)
                } else {
                    list.append(listInfo)
                }
            }
        }
        
        finish(list)
    }
}

public extension HDPhotoLibraryManager {
    
    /// 分页获取图片模型
    class func fetchPhotos(in result: PHFetchResult<PHAsset>, offset: Int = 0, limitCount: Int = .max) -> [HDAssertInfo] {
        
        var infoMap: [HDAssertInfo] = []

        let totalCount = result.count
        
        guard totalCount > 0 else { return infoMap }

        /// 初始位置
        let start = max(0, (totalCount - (offset + limitCount)))
        
        /// 数量
        let max = max(0, totalCount - offset)
        
        if start == max, start == 0 { return infoMap }

        for i in (start ..< max).reversed() {
            guard i < result.count else { continue }
            
            let asset = result[i]
            
            if asset.mediaType == .video {
                continue
            }
                        
            infoMap.append(HDAssertInfo(asset))
        }
        
        return infoMap
    }
}


public extension HDPhotoLibraryManager {
    
    /// Fetch image for asset.
    class func fetchImage(for asset: PHAsset, size: CGSize, resizeMode: PHImageRequestOptionsResizeMode = .fast, deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat, progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void)? = nil, completion: @escaping (UIImage?, Bool) -> Void) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        option.resizeMode = resizeMode
        option.deliveryMode = .highQualityFormat
        option.isNetworkAccessAllowed = true
        option.progressHandler = { (pro, error, stop, info) in
            safeMainThreadClosure {
                progress?(CGFloat(pro), error, stop, info)
            }
        }
        
        return PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: option) { (image, info) in
            var downloadFinished = false
            if let info = info {
                downloadFinished = !(info[PHImageCancelledKey] as? Bool ?? false) && (info[PHImageErrorKey] == nil)
            }
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if downloadFinished {
                completion(image, isDegraded)
            }
        }
    }

}

extension HDPhotoLibraryManager {
    public class func checkAssertIsLocal(asset: PHAsset?) -> Bool {
        guard let asserts = asset else {
            return true
        }
        
        let resourceArray = PHAssetResource.assetResources(for: asserts)
        let bIsLocallayAvailable = (resourceArray.first?.value(forKey: "locallyAvailable") as? Bool) ?? true
        return bIsLocallayAvailable
    }
}

public func safeMainThreadClosure(_ closure: @escaping () -> Void) {
    if Thread.current.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async {
            closure()
        }
    }
}
