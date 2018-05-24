import UIKit

extension UIViewController {
    func toast(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    }
}
