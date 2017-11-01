import UIKit
import Alamofire

class Connectivity {
    class func isConnectedToInternet() throws -> Bool {
        guard let connectivityManager = NetworkReachabilityManager() else {
            throw AttributedError(title: "News reader", description: "No internet connection.")
        }
        return connectivityManager.isReachable
    }
}

public struct AttributedError: LocalizedError {
    let title: String
    let description: String?

    init(title: String?, description: String?) {
        self.title = title ?? "Error"
        self.description = description
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
