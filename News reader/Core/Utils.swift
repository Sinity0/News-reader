import UIKit

public struct CustomError: LocalizedError {
    var title: String
    var description: String? { return _description }

    private var _description: String

    init(title: String?, description: String) {
        self.title = title ?? "Error"
        self._description = description
    }
}

extension UIViewController {
    func showAlert(title:String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(confirm)
        return alertController
    }
}
