import Foundation

class ParentDataModel {
    static let shared = ParentDataModel()

    var parentData: [Parent] = []
    var currentParent: Parent?

    private init() {
        // ✅ Set a complete demo parent to prevent "No parent found" error
        currentParent = Parent(
            name: "Vivek Chaudhary",
            email: "vivek@parent.com",
            phoneNumber: "7817831929",
               // Required field
            gender: .male,    // Required field
            relation:.father        // Required field
        )
    }
}
