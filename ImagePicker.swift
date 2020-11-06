//
//  ImagePicker.swift
//  IMChatSDK
//
//  Created by Linti on 2020/11/5.
//

import UIKit
import Photos

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

class ImagePicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image", "public.movie"]
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }

    public func present(from sourceView: UIView) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        self.presentationController?.present(alertController, animated: true)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)

        self.delegate?.didSelect(image: image)
    }
    
    func uploadMediaFromPicker(with info: [UIImagePickerController.InfoKey: Any]) {
        var filename = String.random()

        if let assetURL = info[.referenceURL] as? URL,
            let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject {
            if let resource = PHAssetResource.assetResources(for: asset).first {
                filename = resource.originalFilename
            }

            let mimeType = UploadHelper.mimeTypeFor(assetURL)

            if mimeType == "image/gif" {
                upload(gif: asset, filename: filename)
//                dismiss(animated: true, completion: nil)
                return
            }
        }

        if let image = info[.originalImage] as? UIImage {
            upload(image: image, filename: filename)
        }

        if let videoURL = info[.mediaURL] as? URL {
            upload(videoWithURL: videoURL, filename: filename)
        }
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        uploadMediaFromPicker(with: info)
        
        let imageUrl = info[.referenceURL] as! NSURL
        print("imageUrl: \(imageUrl)")
        
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate {
}


extension ImagePicker {
    func upload(image: UIImage, filename: String) {
        let file = UploadHelper.file(
            for: image.compressedForUpload,
            name: "\(filename.components(separatedBy: ".").first ?? "image").jpeg",
            mimeType: "image/jpeg"
        )

        upload(file)
    }

    func upload(audioWithURL url: URL, filename: String? = nil) {
        var ext = url.pathExtension

        if ext.isEmpty {
            ext = "m4a"
        }

        guard let data =  try? Data(contentsOf: url) else {
            return
        }

        let file = UploadHelper.file(
            for: data,
            name: filename ?? url.lastPathComponent,
            mimeType: "audio/mp4"
        )

        upload(file)
    }

    func upload(videoWithURL videoURL: URL, filename: String) {
        let assetURL = AVURLAsset(url: videoURL)
        let semaphore = DispatchSemaphore(value: 0)

        UploadVideoCompression.toMediumQuality(sourceAsset: assetURL, completion: { [weak self] (videoData, _) in
            guard let videoData = videoData else {
                semaphore.signal()
                return
            }

            let file = UploadHelper.file(
                for: videoData as Data,
                name: "\(filename.components(separatedBy: ".").first ?? "video").mp4",
                mimeType: "video/mp4"
            )

            semaphore.signal()
            self?.upload(file)
        })

        _ = semaphore.wait(timeout: .distantFuture)
    }

    func upload(gif asset: PHAsset, filename: String) {
        PHImageManager.default().requestImageData(for: asset, options: nil) { [weak self] data, _, _, _ in
            guard let data = data else { return }

            let file = UploadHelper.file(
                for: data,
                name: "\(filename.components(separatedBy: ".").first ?? "image").gif",
                mimeType: "image/gif"
            )

            self?.upload(file)
        }
    }

    func upload(_ file: FileUpload) {
        DispatchQueue.main.async {
//            MBProgressHUD.hide(for: self.view, animated: true)
            self.uploadDialog(file)
        }
    }
    
    func uploadDialog(_ file: FileUpload) {

        let alert = UIAlertController(title: "上传文件", message: "", preferredStyle: .alert)
        var fileName: UITextField?
        var fileDescription: UITextField?

        alert.addTextField { (_ field) -> Void in
            fileName = field
            fileName?.placeholder = "文件名"
            fileName?.text = file.name
        }

        alert.addTextField { (_ field) -> Void in
            fileDescription = field
            fileDescription?.autocorrectionType = .yes
            fileDescription?.autocapitalizationType = .sentences
            fileDescription?.placeholder = "文件描述"
        }

        alert.addAction(UIAlertAction(title: "上传", style: .default, handler: { _ in
            var name = file.name
            if fileName?.text?.isEmpty == false {
                name = fileName?.text ?? file.name
            }

            let description = fileDescription?.text
            
            
            
//            self.upload(file, fileName: name, description: description)
        }))

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        DispatchQueue.main.async {
            guard let parentVC = self.presentationController else { return }
            parentVC.present(alert, animated: true, completion: nil)
        }
    }
    
//    var uploadClient: UploadClient? {
//        return API.current()?.client(UploadClient.self)
//    }
//
//    func upload(_ file: FileUpload, fileName: String, description: String?) {
//
//        uploadClient?.uploadMessage(roomId: "", data: file/Data, filename: fileName, mimetype: file.type, description: "", progress: { [weak self] double in
//
//        }, completion: { [weak self] success in
//
//        })
//    }
}
