import UIKit
import AVFoundation

struct Camera {
    
    var parentViewController : UIViewController!
    
    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }
    
    func requestAuthorizationOn() {
        let status =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if (status == AVAuthorizationStatus.denied) {
            let alert = UIAlertController(title: "Camera access",
                                          message: "Please allow access to camera",
                                          preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Open settings", style: .default) { (_) -> Void in
                let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
                if let url = settingsUrl {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                    }
                }
            }
            alert.addAction(settingsAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            })
            self.parentViewController.present(alert, animated: true)
        }
    }

    func open() {
        requestAuthorizationOn()

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let picker = UIImagePickerController()
            picker.modalPresentationStyle = UIModalPresentationStyle.popover
            picker.delegate = self.parentViewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.sourceType = UIImagePickerControllerSourceType.camera
            if let popover = picker.popoverPresentationController {
                popover.sourceView = self.parentViewController.view
                popover.sourceRect = self.parentViewController.view.frame
                popover.permittedArrowDirections = UIPopoverArrowDirection.any
            }
            self.parentViewController.present(picker, animated: true, completion: nil)
        }
    }
}

