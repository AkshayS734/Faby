import Foundation

class ParentDataModel {
    static let shared = ParentDataModel()

    var parentData: [Parent] = []
    var currentParent: Parent?

    private init() {
      //   ✅ Set a complete demo parent to prevent "No parent found" error
        currentParent = Parent(
             // Provide a unique ID
            name: "Adarsh",
            email: "example@gmail.com",
            gender: .male,
            relation: .father // Provide an empty array or relevant baby IDs
        )
    }
}
