//
//  VideoHelper.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 30/04/21.
//

import UIKit
import MobileCoreServices

enum VideoHelper {
    static func startMediaBrowser(
        delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate,
        sourceType: UIImagePickerController.SourceType
    ) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType)
        else { return }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = sourceType
        mediaUI.mediaTypes = [kUTTypeMovie as String]
        mediaUI.allowsEditing = true
        mediaUI.videoQuality = .typeHigh
        mediaUI.delegate = delegate
        
        delegate.present(mediaUI, animated: true, completion: nil)
    }
}
