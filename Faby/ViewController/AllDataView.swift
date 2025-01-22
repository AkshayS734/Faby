import Foundation
import SwiftUI
import SwiftUICore

struct AllDataView: View {
    var baby: Baby?

    var body: some View {
        VStack {
            List {
                if let height = baby?.height.keys.first {
                    Text("Height: \(height, specifier: "%.2f") \(baby?.height.values.first ?? Date())")
                }
                if let weight = baby?.weight.keys.first {
                    Text("Weight: \(weight, specifier: "%.2f") \(baby?.weight.values.first ?? Date())")
                }
                if let headCircumference = baby?.headCircumference.keys.first {
                    Text("Head Circumference: \(headCircumference, specifier: "%.2f") \(baby?.headCircumference.values.first ?? Date())")
                }
            }
        }
        .navigationTitle("All Data")
    }
}
