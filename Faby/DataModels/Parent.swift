import Foundation

struct Parent {
    var id: String = UUID().uuidString
    var name: String
    var email: String
    var phoneNumber: String?
    var gender: Gender
    var relation: Relation
    var babyIds: [String] = [] // Initialize as an empty array
}

enum Relation : String, Codable{
    case father
    case mother
    case guardian
}
