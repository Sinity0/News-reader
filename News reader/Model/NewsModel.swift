import Foundation
import ObjectMapper

struct NewsModel: Mappable {
    var title: String?
    var description: String?
    var url: String?

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        title <- map["title"]
        description <- map["description"]
        url <- map["url"]
    }
}
