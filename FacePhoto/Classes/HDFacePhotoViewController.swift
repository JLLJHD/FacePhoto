//
//  HDFacePhotoViewController.swift
//  FacePhoto
//
//  Created by chaojie zheng on 2023/2/16.
//

import UIKit
import SnapKit

public class HDFacePhotoViewController: UIViewController {

    public var selectAction: ((HDAssertInfo) -> Void)?
    
    lazy var navView: HDFacePhotoNvaigationView = {
        let item = HDFacePhotoNvaigationView(frame: .zero, superView: self.view)
        item.backgroundColor = .black
        item.back = { [weak self] in
            self?.dismiss(animated: true)
        }
        item.selectCollection = { [weak self] (albumListInfo) in
            self?.albumNavigationBarChange(albumListInfo)
        }
        return item
    }()
    
    let silderLength = (UIScreen.main.bounds.width - 2 * 8 - (3 - 1) * 9 - 0.01) / 3

    lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let item = UICollectionViewFlowLayout()
        item.itemSize = CGSize(width: silderLength, height: silderLength)
        item.minimumLineSpacing = 9
        item.minimumInteritemSpacing = 8
        item.sectionInset = UIEdgeInsets(top: 10, left: 8, bottom: 0, right: 8)
        return item
    }()
    
    lazy var collectionView: UICollectionView = {
        let item = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        item.delegate = self
        item.dataSource = self
        item.register(HDFacePhotoCell.self, forCellWithReuseIdentifier: "HDFacePhotoCell")
        item.backgroundColor = .black
        return item
    }()
    
    let fetchPageSize: Int = 500

    var curCollectionFetchOffset: Int = 0
    
    let handle = HDFaceHandle()

    var dataSource: [HDAssertInfo] = []

    var curSelectAlbumListInfo: HDAlbumListInfo?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        initSubView()
        
        HDPhotoLibraryManager.deviceAuthorization(.photo) { T, S, _ in
            if S == .authorized {
                HDPhotoLibraryManager.getPhotoAlbumList {
                    self.navView.dataMap = $0
                }
            }
        }
    }
    
    func initSubView() {
        view.addSubview(collectionView)
        view.addSubview(navView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        navView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
    func albumNavigationBarChange(_ albumListInfo: HDAlbumListInfo?) {
        curSelectAlbumListInfo = albumListInfo
        curCollectionFetchOffset = 0
        
        self.dataSource.removeAll()
        self.collectionView.reloadData()
        
        fetch()
    }
    
    func fetch() {
        guard let curSelectAlbumListInfo = curSelectAlbumListInfo else { return }
        
        let items = HDPhotoLibraryManager.fetchPhotos(in: curSelectAlbumListInfo.result, offset: curCollectionFetchOffset, limitCount: fetchPageSize)
        self.handle.check(items: items) {[weak self] infoMap in
            guard let `self` = self else { return }
            
            self.curCollectionFetchOffset += infoMap.count

            let models = infoMap.filter({ $0.haveFace })
            let indexPathArr = models.enumerated().map { [weak self] (i, _) -> IndexPath in
                IndexPath(row: self?.dataSource.count ?? 0 + i, section: 0)
            }
            self.dataSource.append(contentsOf: models)
            if self.dataSource.count > 1 {
                self.collectionView.performBatchUpdates {
                    self.collectionView.insertItems(at: indexPathArr)
                }
            } else {
                self.collectionView.reloadData()
                self.collectionView.layoutIfNeeded()
            }
            
        } complete: {[weak self] hadFace, _ in
            guard let `self` = self else { return }
            
            if self.curCollectionFetchOffset < curSelectAlbumListInfo.result.count {
                self.fetch()
            }
        }
    }

}

extension HDFacePhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HDFacePhotoCell", for: indexPath) as! HDFacePhotoCell
        cell.config(data: dataSource[indexPath.item])
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectAction?(dataSource[indexPath.item])
    }
}
