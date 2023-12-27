//
//  HDPhotoLibraryManager.Authorization.swift
//  FacePhoto
//
//  Created by chaojie zheng on 2023/2/15.
//

import UIKit
import Photos
import AVFoundation

public enum HDDevicePrivacyType {
    case camera
    case photo
}

public enum HDAuthorizationStatus {
    case unknow
    case notDetermined
    case restricted
    case denied
    case authorized
    case limited
}

public extension HDPhotoLibraryManager {
    
    typealias authorizationResult = (HDDevicePrivacyType, HDAuthorizationStatus, Bool) -> Void
    
    class func deviceAuthorization(_ mediaType: HDDevicePrivacyType, _ result : @escaping authorizationResult) {
        switch mediaType {
        case .camera:
            HDPhotoLibraryManager.cameraAuthorization(result: result)
        case .photo:
            HDPhotoLibraryManager.photoAuthorization(result: result)
        }
    }
    
    private class func cameraAuthorization(result: @escaping authorizationResult) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { (agree) in
                    DispatchQueue.main.async {
                        if agree {
                            result(.camera, .authorized, false)
                        } else {
                            result(.camera, .denied, false)
                        }
                    }
                }
            case .authorized:
                result(.camera, .authorized, true)
            case .denied:
                result(.camera, .denied, true)
            case .restricted:
                result(.camera, .restricted, true)
            @unknown default:
                result(.camera, .unknow, true)
            }
        } else {
            result(.camera, .unknow, true)
        }
    }
    
    private class func photoAuthorization(result: @escaping authorizationResult) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { (Status) in
                    DispatchQueue.main.async {
                        switch Status {
                        case .authorized:
                            result(.photo, .authorized, false)
                        case .denied:
                            result(.photo, .denied, false)
                        case .notDetermined:
                            result(.photo, .notDetermined, false)
                        case .restricted:
                            result(.photo, .restricted, false)
                        case .limited :
                            result(.photo, .limited, false)
                        @unknown default:
                            result(.photo, .unknow, false)
                        }
                    }
                }
            case .authorized:
                result(.photo, .authorized, true)
            case .denied:
                result(.photo, .denied, true)
            case .restricted:
                result(.photo, .restricted, true)
            case .limited :
                result(.photo, .limited, true)
            @unknown default:
                result(.photo, .unknow, true)
            }
        } else {
            result(.photo, .unknow, true)
        }
    }
}
