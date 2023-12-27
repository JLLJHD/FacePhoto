//
//  HDFacePhotoCellModel.swift
//  FacePhoto
//
//  Created by chaojie zheng on 2023/2/16.
//

import UIKit
import Photos

class HDFacePhotoCellModel {

    let sideLength = UIScreen.main.bounds.width * UIScreen.main.scale / 3

    var getImageFinish: ((UIImage?) -> Void)?

    var isiCloudCheckFinish: ((Bool) -> Void)?

    init(model: HDAssertInfo, getImageFinish: ((UIImage?) -> Void)?, isiCloudCheckFinish: ((Bool) -> Void)?) {
        guard let asset = model.asset else { return }
        
        self.getImageFinish = getImageFinish
        self.isiCloudCheckFinish = isiCloudCheckFinish
        
        _ = HDPhotoLibraryManager.fetchImage(for: asset, size: CGSize(width: sideLength, height: sideLength), resizeMode: .fast, deliveryMode: .opportunistic) {[weak self] image, _ in
            self?.getImageFinish?(image)
        }
        
        isiCloudCheckFinish?(model.isiCloud)        
    }

}
