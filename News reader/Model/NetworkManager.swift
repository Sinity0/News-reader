import Foundation
import Alamofire
import AlamofireObjectMapper

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}

public class NetworkManager {

    typealias NewsCompletion = (Result<[NewsModel]>) -> Void

    func fetchTrendedGifs(source: String, sortBy: String, completionHandler: @escaping NewsCompletion) {

        request(url: Constants.url, parameters: getParameters(source: source, sortBy: sortBy)) { result -> Void in
            completionHandler(result)
        }
    }

    private func getParameters(source: String, sortBy: String) -> [String: Any] {

        let parameters: [String: Any] = [
            "source": source,
            "sortBy": sortBy,
            "apiKey": Constants.apiKey
        ]
        return parameters
    }

    private func request(url: String, parameters: [String: Any], completion: @escaping NewsCompletion) {
        
        Alamofire.request(url,
                          method: .get,
                          parameters: parameters,
                          encoding: URLEncoding.default).responseArray(keyPath: "articles") { (response: DataResponse<[NewsModel]>) in

                            switch response.result {

                            case .failure(let error):
                                completion(.failure(error))
                            case .success(let value):
                                completion(.success(value))
                            }
        }
    }
    
}
