import Foundation

struct VaccineSchedule {
    let type: String
    let hospital: String
    let date: String
    let location: String
}

struct VaccinationSchedule {
    let id: UUID
    let type: String
    let hospitalName: String
    let hospitalAddress: String
    let scheduledDate: String
    let babyId: UUID
}

// MARK: - Storage Manager
class VaccinationStorageManager {
    static let shared = VaccinationStorageManager()
    
    // Dictionary to store schedules with UUID as key and VaccinationSchedule as value
    private var schedules: [UUID: VaccinationSchedule] = [:]
    
    private init() {}
    
    func saveSchedule(_ schedule: VaccinationSchedule) {
        schedules[schedule.id] = schedule
    }
    
    func getAllSchedules() -> [VaccinationSchedule] {
        return Array(schedules.values)
    }
    
    func getSchedulesForBaby(babyId: UUID) -> [VaccinationSchedule] {
        return schedules.values.filter { $0.babyId == babyId }
    }
    
    func deleteSchedule(id: UUID) {
        schedules.removeValue(forKey: id)
    }
}
