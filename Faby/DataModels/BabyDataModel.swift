import Foundation

class BabyDataModel {
    static let shared = BabyDataModel()
    
    var babyList: [Baby] = [
        Baby(
            name: "Deepak",
            dateOfBirth: "28092024",
            gender: .male,
            parent: Parent(
                id: String(), // Provide a unique ID
                name: "Adarsh",
                email: "example@gmail.com",
                gender: .male,
                relation: .father,
                babyIds: [] // Provide an empty array or relevant baby IDs
            )
        )
    ]
}
