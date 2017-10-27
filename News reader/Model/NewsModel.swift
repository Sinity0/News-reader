import Foundation
import ObjectMapper

public struct NewsModel: Mappable {
    public var title: String?
    public var description: String?
    public var url: String?

    public init?(map: Map) {
    }

    public init?(title: String, description: String, url: String) {
        self.title = title
        self.description = description
        self.url = url
    }

    mutating public func mapping(map: Map) {
        title <- map["title"]
        description <- map["description"]
        url <- map["url"]
    }
}
