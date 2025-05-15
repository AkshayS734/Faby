import Foundation
import SwiftUI

struct VaccineCardsView: View {
    @State private var displayedVaccines: [(VaccineSchedule, String)]
    let vaccines: [(VaccineSchedule, String)]
    var onVaccineCompleted: ((VaccineSchedule, String)) -> Void
    var onVaccineCardTapped: ((VaccineSchedule, String)) -> Void
    
    init(vaccines: [(VaccineSchedule, String)],
         onVaccineCompleted: @escaping ((VaccineSchedule, String)) -> Void,
         onVaccineCardTapped: @escaping ((VaccineSchedule, String)) -> Void) {
        self.vaccines = vaccines
        self._displayedVaccines = State(initialValue: vaccines)
        self.onVaccineCompleted = onVaccineCompleted
        self.onVaccineCardTapped = onVaccineCardTapped
    }
    
    var body: some View {
        VStack {
            if displayedVaccines.isEmpty {
                emptyVaccineView
            } else {
                vaccineCardsListView
            }
        }
        .frame(height: 160)
        .background(Color.clear) // Using transparent background to blend with main screen
    }
    
    // Break down complex SwiftUI expressions into smaller views
    private var emptyVaccineView: some View {
        HStack {
            Image(systemName: "syringe")
                .font(.system(size: 24))
                .foregroundColor(.white)
            Text("No upcoming vaccinations")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .frame(height: 100)
        .padding(16)
        /*.background(Color.clear)*/ // Using transparent background to blend with main screen
//        .cornerRadius(16)
    }
    
    private var vaccineCardsListView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(Array(displayedVaccines.enumerated()), id: \.element.0.id) { index, tuple in
                    vaccineCardView(for: tuple)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
        }
        .frame(height: 120)
        .background(Color.clear) // Using transparent background to blend with main screen
        .animation(.default, value: displayedVaccines.count)
    }
    
    private func vaccineCardView(for tuple: (VaccineSchedule, String)) -> some View {
        let (vaccine, vaccineName) = tuple
        return VaccineCard(
            vaccine: vaccine,
            vaccineName: vaccineName,
            onComplete: {
                handleVaccineCompletion(vaccine: vaccine, tuple: tuple)
            },
            onCardTapped: {
                onVaccineCardTapped(tuple)
            }
        )
    }
    
    private func handleVaccineCompletion(vaccine: VaccineSchedule, tuple: (VaccineSchedule, String)) {
        print("📱 Vaccine card tapped for completion: \(vaccine.vaccineId)")
        // Use withAnimation to smoothly remove the card
        withAnimation(.easeOut(duration: 0.3)) {
            // Find and remove the completed vaccine from our local array
            if let index = displayedVaccines.firstIndex(where: { $0.0.id == vaccine.id }) {
                displayedVaccines.remove(at: index)
            }
        }
        // Call the completion handler to update the parent view/model
        onVaccineCompleted(tuple)
    }
}

struct VaccineCard: View {
    let vaccine: VaccineSchedule
    let vaccineName: String
    let onComplete: () -> Void
    let onCardTapped: () -> Void
    @State private var isCompleted: Bool
    @State private var showConfirmation = false
    @State private var showReschedulePrompt = false
    
    init(vaccine: VaccineSchedule,
         vaccineName: String,
         onComplete: @escaping () -> Void,
         onCardTapped: @escaping () -> Void) {
        self.vaccine = vaccine
        self.vaccineName = vaccineName
        self.onComplete = onComplete
        self.onCardTapped = onCardTapped
        _isCompleted = State(initialValue: vaccine.isAdministered)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Vaccine Name and Icon
            HStack {
                Image(systemName: "syringe")
                    .font(.system(size: 16))
                    .foregroundColor(Color(.systemBlue))
                    .frame(width: 24)
                
                Text(vaccineName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                Button(action: {
                    showConfirmation = true
                }) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .green : Color(.systemGray3))
                        .font(.system(size: 22))
                }
                .disabled(isCompleted)
            }
            .contentShape(Rectangle()) // Make entire row tappable
            
            // Date and Hospital Info
            VStack(alignment: .leading, spacing: 8) {
                // Create a variable for formatted date string outside the HStack
                let formattedDate: String = {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    return dateFormatter.string(from: vaccine.date)
                }()
                
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(.systemGray))
                        .font(.system(size: 14))
                        .frame(width: 16)
                    
                    Text(formattedDate)
                        .font(.system(size: 14))
                        .foregroundColor(Color(.darkGray))
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "building.2")
                        .foregroundColor(Color(.systemGray))
                        .font(.system(size: 14))
                        .frame(width: 16)
                    
                    Text(vaccine.hospital)
                        .font(.system(size: 14))
                        .foregroundColor(Color(.darkGray))
                        .lineLimit(1)
                }
            }
        }
        .padding(16)
        .frame(width: 280, height: 130)
        .background(Color.white) // Changed from .clear to .white
        .cornerRadius(16)
        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 6, x: 0, y: 2)
        .contentShape(Rectangle()) // Make entire card tappable
        .onTapGesture {
            onCardTapped()
        }
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("Confirm Vaccination"),
                message: Text("Has this \(vaccineName) vaccine been administered to your child?"),
                primaryButton: .default(Text("Yes")) {
                    isCompleted = true
                    // Just call onComplete immediately - the parent view will handle the animation
                    onComplete()
                },
                secondaryButton: .cancel(Text("No")) {
                    // Just close the dialog without any action
                }
            )
        }
        .sheet(isPresented: $showReschedulePrompt) {
            RescheduleVaccineView(vaccine: vaccine, vaccineName: vaccineName)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct RescheduleVaccineView: View {
    let vaccine: VaccineSchedule
    let vaccineName: String
    @State private var selectedDate = Date()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Reschedule \(vaccineName)")
                    .font(.headline)
                    .padding(.top)
                
                DatePicker(
                    "Select New Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                Button(action: {
                    // Here you would implement the actual rescheduling logic
                    // connecting to your VaccineScheduleManager
                    Task {
                        do {
                            try await VaccineScheduleManager.shared.updateSchedule(
                                recordId: vaccine.id,
                                newDate: selectedDate,
                                newHospital: Hospital(
                                    id: UUID(),
                                    babyId: vaccine.babyID,
                                    name: vaccine.hospital,
                                    address: vaccine.location,
                                    distance: 0.0
                                )
                            )
                            // Post notification to refresh the view
                            NotificationCenter.default.post(
                                name: NSNotification.Name("NewVaccineScheduled"),
                                object: nil
                            )
                        } catch {
                            print("Failed to reschedule vaccine: \(error)")
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save New Date")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
