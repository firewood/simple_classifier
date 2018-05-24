import Foundation
import Photos

struct PhotoPicker {

    var parentViewController : UIViewController!
    
    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }

    func requestAuthorizationOn() {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.denied) {
            let alert = UIAlertController(title: "Photo library access",
                                          message: "Please allow access to photo library",
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

    func callPhotoLibrary(){
        requestAuthorizationOn()

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {

            let picker = UIImagePickerController()
            picker.modalPresentationStyle = UIModalPresentationStyle.popover
            picker.delegate = self.parentViewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            if let popover = picker.popoverPresentationController {
                popover.sourceView = self.parentViewController.view
                popover.sourceRect = self.parentViewController.view.frame
                popover.permittedArrowDirections = UIPopoverArrowDirection.any
            }
            self.parentViewController.present(picker, animated: true, completion: nil)
        }
    }
}
