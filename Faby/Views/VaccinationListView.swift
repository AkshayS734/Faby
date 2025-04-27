import SwiftUI

struct VaccinationListView: View {
    let vaccinations: [VaccineSchedule]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if vaccinations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No vaccinations scheduled")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else {
                    ForEach(vaccinations, id: \.id) { vaccination in
                        VaccinationCardView(
                            vaccineName: getVaccineName(for: vaccination.vaccineId),
                            hospitalName: vaccination.hospital,
                            date: vaccination.date,
                            isAdministered: vaccination.isAdministered
                        )
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // Helper method to get vaccine name (temporary solution)
    private func getVaccineName(for vaccineId: UUID) -> String {
        let vaccineNames = [
            "DTaP (Dose 1)",
            "Hepatitis B (Dose 1)",
            "Rotavirus",
            "Polio (Dose 1)",
            "Hib (Dose 1)",
            "Pneumococcal (Dose 1)"
        ]
        
        if let lastChar = vaccineId.uuidString.last,
           let index = Int(String(lastChar), radix: 16) {
            return vaccineNames[index % vaccineNames.count]
        }
        
        return "Vaccine"
    }
}

// Preview Provider
struct VaccinationListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview with vaccinations
            VaccinationListView(vaccinations: [
                VaccineSchedule(
                    id: UUID(),
                    babyID: UUID(),
                    vaccineId: UUID(),
                    hospital: "City Hospital",
                    date: Date(),
                    location: "123 Medical St",
                    isAdministered: false
                ),
                VaccineSchedule(
                    id: UUID(),
                    babyID: UUID(),
                    vaccineId: UUID(),
                    hospital: "Medical Center",
                    date: Date().addingTimeInterval(86400),
                    location: "456 Health Ave",
                    isAdministered: true
                )
            ])
            
            // Preview empty state
            VaccinationListView(vaccinations: [])
                .preferredColorScheme(.dark)
        }
    }
} 