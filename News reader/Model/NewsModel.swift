import Foundation
import ObjectMapper

struct NewsModel: Mappable {
    var title: String?
    var description: String?
    var url: String?

    init?(map: Map) {
    }

    init?(title: String, description: String, url: String) {
        self.title = title
        self.description = description
        self.url = url
    }

    mutating func mapping(map: Map) {
        title <- map["title"]
        description <- map["description"]
        url <- map["url"]
    }
}
