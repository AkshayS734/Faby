import Foundation

class BabyDataModel {
    static let shared = BabyDataModel()
    
    var babyList: [Baby] = [
        Baby(
            babyId: UUID(),
            name: "Deepak",
            dateOfBirth: "28092024",
            gender: .male
        )
    ]
}
