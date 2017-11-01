import Foundation
import Alamofire
import AlamofireObjectMapper

public enum sortBy {
    case top, latest
}

public class NetworkManager {
    public typealias NewsCompletion = (Alamofire.Result<[[String: Any]]>) -> Void

    public func fetchNews(source: String, sortBy: sortBy, completionHandler: @escaping NewsCompletion) {
        request(url: Constants.url, parameters: getParameters(source: source, sortBy: sortBy)) { result -> Void in
            completionHandler(result)
        }
    }

    private func getParameters(source: String, sortBy: sortBy) -> [String: Any] {
        let parameters: [String: Any] = [
            "source": source,
            "sortBy": sortBy == .top ? "top" : "latest",
            "apiKey": Constants.apiKey
        ]
        return parameters
    }

    public func request(url: String, parameters: [String: Any], completion: @escaping NewsCompletion) {
        Alamofire.request(url,
                          method: .get,
                          parameters: parameters,
                          encoding: URLEncoding.default).responseJSON( completionHandler: { response in

            switch response.result {

            case .failure(let error):
                print(error)
                completion(.failure(error))
            case .success(let value):

                if let json = value as? [String: Any] {
                    guard let articles = json["articles"] as? [[String: Any]] else { return }
                    completion(.success(articles))
                }
            }
        })
    }
}
