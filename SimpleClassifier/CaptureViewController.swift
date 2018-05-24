import UIKit
import Photos

func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}

class CaptureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var imageView: UIImageView!

    var label:String = ""
    var pinchCenter : CGPoint!
    var pinchImageOrigin:CGPoint!
    var pinchImageSize:CGSize!
    let labels = ["hinoki", "kuwa", "matsu", "sakura"];

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPinchInout()
        label = labels[0]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return labels.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return labels[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        label = labels[row];
    }

    @IBAction func onCameraTouched(_ sender: Any) {
        let camera:Camera = Camera(parentViewController: self)
        camera.open()
    }

    @IBAction func onPickupTouched(_ sender: Any) {
        let photo_picker:PhotoPicker = PhotoPicker(parentViewController: self)
        photo_picker.callPhotoLibrary()
    }

    @IBAction func onUploadTouched(_ sender: Any) {
        if let image = getRetouchedImage() {
            let imageUploader:ImageUploader = ImageUploader()
            imageUploader.upload(label: label, image:image, callback: {(url: String?) -> Void in
                if let url = url {
                    let message = "SUCCESS!\n\(url)"
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    })
                    self.present(alert, animated: true, completion: nil)
                    self.resetImageViewFrame()
                } else {
                    self.toast(message: "FAILED")
                }
            })
        }
    }

    @IBAction func onCheckTouched(_ sender: Any) {
        if let image = getRetouchedImage() {
            let pixelBuffer:CVPixelBuffer? = image.resize(to: CGSize(width: 224.0, height: 224.0)).pixelBuffer()
            let model = Leaves()
            var output:LeavesOutput
            do {
                output = try model.prediction(input__0: pixelBuffer!)
            } catch let error as NSError {
                self.toast(message: "ERROR: \(error)")
                return
            }
            let message = "Result:\n" + output.final_result__0.map { (key:String, value:Double) -> String in
                return String(format: "%@: %.2f%%", key, value * 100.0)
            }.joined(separator: "\n")
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            })
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func onResetTapped(_ sender: Any) {
        self.resetImageViewFrame()
    }

    func getRetouchedImage() -> UIImage? {
        if imageView.image != nil {
            UIGraphicsBeginImageContextWithOptions(frameView.bounds.size, frameView.isOpaque, 0.0)
            defer { UIGraphicsEndImageContext() }
            if let context = UIGraphicsGetCurrentContext() {
                frameView.layer.render(in: context)
                return UIGraphicsGetImageFromCurrentImageContext()
            }
        }
        return nil
    }

    func setupPinchInout() {
        let pinchGetsture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(sender:)))
        pinchGetsture.delegate = self as? UIGestureRecognizerDelegate
        self.imageView.addGestureRecognizer(pinchGetsture)
    }

    func resetImageViewFrame() {
        if let image = imageView.image {
            let ratio = self.view.frame.size.width / image.size.width
            imageView.frame = CGRect(x: 0, y: 0, width: image.size.width * ratio, height: image.size.height * ratio)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView!.image = image
        self.resetImageViewFrame()
        picker.dismiss(animated: true, completion: nil)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        if let touchedView = touch.view {
            if touchedView == imageView {
                let location = touch.location(in: imageView)
                let prevLocation = touch.previousLocation(in: imageView)
                imageView.frame.origin.x += location.x - prevLocation.x
                imageView.frame.origin.y += location.y - prevLocation.y
            }
        }
    }

    @objc func pinchAction(sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .began:
            pinchImageOrigin = imageView.frame.origin
            pinchImageSize = imageView.frame.size
            let touchPoint1 = sender.location(ofTouch: 0, in: view)
            let touchPoint2 = sender.location(ofTouch: 1, in: view)
            pinchCenter = CGPoint(x: (touchPoint1.x + touchPoint2.x) / 2, y: (touchPoint1.y + touchPoint2.y) / 2)
        default:
            let minScale = view.frame.width / pinchImageSize.width
            let maxScale = view.frame.width * 10.0 / pinchImageSize.width
            let scale:CGFloat = clamp(value:sender.scale, lower: minScale, upper: maxScale)
            let x = pinchCenter.x - (pinchCenter.x - pinchImageOrigin.x) * scale
            let y = pinchCenter.y - (pinchCenter.y - pinchImageOrigin.y) * scale
            imageView.frame.origin = CGPoint(x: x, y: y)
            imageView.frame.size = CGSize(width: pinchImageSize.width * scale, height: pinchImageSize.height * scale)
        }
    }
}
