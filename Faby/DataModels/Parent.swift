import Foundation

struct Parent  {
    var id: String
    var name : String
    var email : String
    var phoneNumber : String?
    var gender : Gender
    var relation : Relation
    var parentimage_url: String?
    
}

enum Relation : String, Codable{
    case father
    case mother
    case guardian
}

enum Gender: String, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
}
