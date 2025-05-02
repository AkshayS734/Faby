import Foundation

class ParentDataModel {
    static let shared = ParentDataModel()

    var parentData: [Parent] = []
    var currentParent: Parent?

    private init() {
        // Use the actual user ID
        currentParent = Parent(
            id: "",  // Your actual user ID
            name: "Adarsh",
            email: "example@gmail.com",
            gender: .male,
            relation: .father,
            babyIds: []
        )
    }
}
