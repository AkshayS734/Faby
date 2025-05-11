import Foundation

struct Parent  {
    var id: String
    var name : String
    var email : String
    var phoneNumber : String?
    var gender : Gender
    var relation : Relation
    var babyIds: [String]
    var parentimage_url: String?
   // var postIds: [String] = [] // Store post IDs instead of full posts
    //var replyIds: [String] = [] // Store reply IDs separately
    // Track all categories the parent has posted in
    //var categoriesPostedIn: Set<String> = []
    
}

enum Relation : String, Codable{
    case father
    case mother
    case guardian
}
