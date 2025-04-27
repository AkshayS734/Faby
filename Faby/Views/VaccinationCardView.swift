import SwiftUI

struct VaccinationCardView: View {
    let vaccineName: String
    let hospitalName: String
    let date: Date
    let isAdministered: Bool
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Vaccine Name
            Text(vaccineName)
                .font(.headline)
                .fontWeight(.bold)
            
            // Hospital and Status
            HStack(spacing: 6) {
                Circle()
                    .fill(isAdministered ? Color.green : Color.blue)
                    .frame(width: 8, height: 8)
                
                Text(isAdministered ? "Administered" : "Scheduled")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                
                Text("•")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                
                Text(hospitalName)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            
            // Date
            Text(dateFormatter.string(from: date))
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color(.systemGray4).opacity(0.5),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// Preview Provider
struct VaccinationCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light Mode Preview
            VaccinationCardView(
                vaccineName: "DTaP (Dose 1)",
                hospitalName: "City Hospital",
                date: Date(),
                isAdministered: false
            )
            .previewLayout(.sizeThatFits)
            .padding()
            
            // Dark Mode Preview
            VaccinationCardView(
                vaccineName: "Hepatitis B",
                hospitalName: "Medical Center",
                date: Date(),
                isAdministered: true
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.dark)
        }
    }
} 