import Foundation
import UIKit
import Alamofire

class ImageUploader {
    func upload(label: String, image: UIImage, callback: @escaping (String?) -> Void) {
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(UIImagePNGRepresentation(image)!, withName: "image", fileName: "temp.png", mimeType: "image/png")
                multipartFormData.append(label.data(using: String.Encoding.utf8)!, withName: "label")
            },
            to: "http://192.168.0.15:3000/post_image.json",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if response.result.value is NSDictionary {
                            let JSON = response.result.value as! NSDictionary
                            let image = JSON["image"] as! NSDictionary? ?? [:]
                            let url = image["url"] as! String?
                            callback(url)
                        } else {
                            callback(nil)
                        }
                    }
                case .failure:
                    callback(nil)
                }
            }
        )
    }
}
