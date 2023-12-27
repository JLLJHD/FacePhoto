//
//  HDFacePhotoNvaigationView.swift
//  FacePhoto
//
//  Created by chaojie zheng on 2023/2/16.
//

import UIKit
import SnapKit

class HDFacePhotoNvaigationView: UIView {
    
    deinit {
        print("HDFacePhotoNvaigationView deinit")
    }
    
    var curSelectCollection: HDAlbumListInfo? {
        didSet {
            titleItem.setTitle(curSelectCollection?.title, for: .normal)
        }
    }
    
    var dataMap: [HDAlbumListInfo] = [HDAlbumListInfo]() {
        didSet {
            curSelectCollection = dataMap.first
            curSelectCollection?.isSelect = true
            selectCollection?(curSelectCollection)
            
            listCollectionView.reloadData()
        }
    }
    
    var back: (() -> Void)?
    
    var selectCollection: ((HDAlbumListInfo?) -> Void)?
    
    let listHeight = CGFloat(76 * 6)
                
    lazy var backItem: UIButton = {
        let item = UIButton(type: .custom)
        item.setImage(UIImage.image(named: "hd_album_navigation_back_icon"), for: .normal)
        item.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        return item
    }()
    
    lazy var titleItem: UIButton = {
        let item = UIButton(type: .custom)
        item.setTitleColor(.white, for: .normal)
        item.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        item.titleLabel?.lineBreakMode = .byClipping
        item.setImage(UIImage.image(named: "hd_album_nav_icon_arrow"), for: .normal)
        item.setImage(UIImage.image(named: "hd_album_nav_icon_arrow"), for: .highlighted)
        item.setImageTitleLayout(.imgRight, spacing: 4)
        item.addTarget(self, action: #selector(titleItemClickAction), for: .touchUpInside)
        item.imageView?.transform = CGAffineTransform.identity
        return item
    }()
    
    lazy var bgMaskView: UIView = {
        let maskV = UIView()
        maskV.backgroundColor = .black.withAlphaComponent(0.7)
        maskV.alpha = 0
        maskV.isUserInteractionEnabled = true
        maskV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(titleItemClickAction)))
        return maskV
    }()
    
    lazy var listContentView: UIView = {
        let list = UIView()
        list.backgroundColor = .black
        return list
    }()
    
    lazy var listCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: 76)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.delegate = self
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.register(HDAlbumPhotosCollectionCell.self, forCellWithReuseIdentifier: "HDAlbumPhotosCollectionCell")
        return collection
    }()
    
    /// 强制隐藏返回按钮
    var forceHiddenBackItem = false {
        didSet {
            if forceHiddenBackItem {
                backItem.isHidden = true
            }
        }
    }
    
    weak var curSuperView: UIView?
    
    init(frame: CGRect, superView: UIView) {
        super.init(frame: frame)
        backgroundColor = .clear
        curSuperView = superView
        setupSubviews()
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let superView = superview, bgMaskView.superview == nil {
            superView.addSubview(bgMaskView)
            superView.addSubview(listContentView)
            listContentView.addSubview(listCollectionView)
            listContentView.frame = CGRect(x: 0, y: frame.maxY, width: UIScreen.main.bounds.width, height: 0)
            listCollectionView.frame = listContentView.bounds

            
            bgMaskView.snp.makeConstraints { make in
                make.top.equalTo(UIDevice.safeDistanceTop() + 44)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
    }
    
    func setupSubviews() {
        addSubview(backItem)
        addSubview(titleItem)
        
        backItem.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(6)
            make.width.height.equalTo(44)
            make.centerY.equalToSuperview()
        }
        
        titleItem.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview()
        }
        
    }
    
    func refreshBackItemState(hidden: Bool) {
        backItem.isHidden = hidden
    }
    
    @objc func backAction() {
        back?()
    }
    
    @objc func titleItemClickAction() {
        titleItem.isSelected = !titleItem.isSelected
        if titleItem.isSelected {
            expandList()
        } else {
            closeList()
        }
    }
    
    func expandList() {
        UIView.animate(withDuration: 0.2) {
            self.titleItem.imageView?.transform = CGAffineTransform(rotationAngle: 0.999 * .pi)
            self.bgMaskView.alpha = 1
            self.listContentView.frame.size.height = self.listHeight
            self.listCollectionView.frame.size.height = self.listHeight
        }
        
        UIView.animate(withDuration: 0.1) {
            self.backItem.isHidden = true
        }
    }
    
    func closeList() {
        UIView.animate(withDuration: 0.2) {
            self.titleItem.imageView?.transform = CGAffineTransform.identity
            self.bgMaskView.alpha = 0
            self.listContentView.frame.size.height = 0
            self.listCollectionView.frame.size.height = 0
        }
        
        if !forceHiddenBackItem {
            UIView.animate(withDuration: 0.1) {
                self.backItem.isHidden = false
            }
        }
    }
    
}


extension HDFacePhotoNvaigationView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataMap.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HDAlbumPhotosCollectionCell", for: indexPath) as! HDAlbumPhotosCollectionCell
        cell.setData(model(index: indexPath.item))
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectModel(model(index: indexPath.item))
        titleItemClickAction()
    }
    
    func selectModel(_ model: HDAlbumListInfo) {
        curSelectCollection?.isSelect = false
        model.isSelect = true
        curSelectCollection = model
        selectCollection?(model)
    }
    
    func model(index: Int) -> HDAlbumListInfo {
        dataMap[index]
    }
}

/// AlbumPhotosCollectionCell
class HDAlbumPhotosCollectionCell: UICollectionViewCell {
    
    lazy var selectIcon: UIImageView = {
        let imv = UIImageView()
        imv.image = UIImage.image(named:"hd_album_nav_collection_select_icon")
        imv.isHidden = true
        contentView.addSubview(imv)
        imv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
        return imv
    }()
    
    lazy var imageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        imv.layer.masksToBounds = true
        imv.layer.cornerRadius = 4
        contentView.addSubview(imv)
        imv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
            make.width.height.equalTo(62)
        }
        return imv
    }()
    
    lazy var labContentView: UIView = {
        let v = UIView()
        contentView.addSubview(v)
        v.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(40)
        }
        return v
    }()
    
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        labContentView.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        return lab
    }()
    
    lazy var countLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .lightGray
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        labContentView.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.top.equalTo(titleLab.snp.bottom).offset(5)
        }
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(_ model: HDAlbumListInfo) {
        titleLab.text = model.title
        countLab.text = "\(model.result.count)"
        model.fetchHeadAssetImage(imageSize: CGSize(width: 62, height: 62)) { [weak self] image in
            self?.imageView.image = image
        }
        selectIcon.isHidden = !model.isSelect
        model.selectStateChange = {[weak self] value in
            self?.selectIcon.isHidden = !value
        }
    }
}
