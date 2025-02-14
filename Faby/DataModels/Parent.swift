import Foundation

struct Parent  {
    var id: UUID
    var name : String
    var email : String
    var phoneNumber : String?
    var gender : Gender
    var relation : Relation
    var babyIds: [String]
}

enum Relation : String, Codable{
    case father
    case mother
    case guardian
}
