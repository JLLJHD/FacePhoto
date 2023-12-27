//
//  HDUserDefault.swift
//  FacePhoto
//
//  Created by chaojie zheng on 2023/2/15.
//


public protocol HDUserDefault {
    associatedtype T: Any
    static var key: String { get }
    static var value: T? { get set }
}

public extension HDUserDefault {
    static var key: String {
        var name = "\(Self.self)"

        if let range = name.range(of: "HD") {
            name.removeSubrange(range)
        }
        if name.contains(".") {
            name = String(name.split(separator: ".").last!)
        }
        return name.lowercased()
    }

    static var value: T? {
        get {
            UserDefaults.standard.value(forKey: key) as? T
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
}

/// 相册人脸检测缓存
public struct HDAlbumCacheDict: HDUserDefault {
    public typealias T = [String: Bool]
}
