import Foundation

struct Parent{
    var name : String
    var email : String
    var phoneNumber : String?
    var gender : Gender
    var relation : Relation
    var baby : [Baby]?
}

enum Relation : String, Codable{
    case father
    case mother
    case guardian
}
enum Gender {
    case male
    case female
}
