//
//  RecordVideoController.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 30/04/21.
//

import UIKit
import AVKit
import MobileCoreServices

extension EditorController {
    @objc func video(
        _ videoPath: String,
        didFinishSavingWithError error: Error?,
        contextInfo info: AnyObject
    ) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        let alert = UIAlertController(
            title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditorController: UIImagePickerControllerDelegate {
    
    private func thumbnailForVideoAtURL(url: URL) -> UIImage? {

        let asset = AVAsset(url: url as URL)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true

        var time = asset.duration
        time.value = min(time.value, 2)

        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print("error")
            return nil
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        guard
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
            
            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
        else {return}
        
        switch sourceHandler {
        case "Camera":
            UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
            print("Camera, saved to library.")
        case "Album":
            print("Album, nothing to be saved.")
            break
        case .none:
            break
        case .some(_):
            break
        }
        
        self.playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        self.videoUrlHandler = url
        self.videoThumbnailHandler = self.thumbnailForVideoAtURL(url: url)
        self.videoThumbnail.image = self.videoThumbnailHandler
        
//        dismiss(animated: true) {
//            self.playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
//            self.videoUrlHandler = url
//            self.videoThumbnailHandler = self.thumbnailForVideoAtURL(url: url)
//            self.videoThumbnail.image = self.videoThumbnailHandler
//        }
    }
}

// MARK: - UINavigationControllerDelegate
extension EditorController: UINavigationControllerDelegate {
    
}
