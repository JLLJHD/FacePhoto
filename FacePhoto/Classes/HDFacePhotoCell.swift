//
//  HDFacePhotoCell.swift
//  FacePhoto
//
//  Created by chaojie zheng on 2023/2/16.
//

import UIKit
import SnapKit

class HDFacePhotoCell: UICollectionViewCell {
    
    var model: HDFacePhotoCellModel?
    
    lazy var icloudIcon: UIImageView = {
        let item = UIImageView.init(image: UIImage.image(named: "photo_icon_icloud"))
        return item
    }()
    
    public var isiCloud: Bool = false {
        didSet {
            icloudIcon.isHidden = !isiCloud
        }
    }
    
    lazy var imageV: UIImageView = {
        let item = UIImageView.init(frame: .zero)
        item.contentMode = .scaleAspectFill
        item.layer.cornerRadius = 6
        item.layer.masksToBounds = true
        return item
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageV)
        imageV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(icloudIcon)
        icloudIcon.snp.remakeConstraints { (make) in
            make.size.equalTo(CGSize(width: 16, height: 16))
            make.top.trailing.equalToSuperview().inset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(data model: HDAssertInfo) {
        
        self.model = HDFacePhotoCellModel(model: model, getImageFinish: {[weak self] img in
            self?.imageV.image = img
        }, isiCloudCheckFinish: {[weak self] isiCloud in
            self?.isiCloud = isiCloud
        })
    }
}
