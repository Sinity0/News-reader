import UIKit

extension UIViewController {
    func showAlert(_ message: String) -> UIAlertController {
        let alertController = UIAlertController(title: "Gifer", message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(confirm)
        return alertController
    }
}
