import Foundation
import Supabase

struct VaccineStage {
    let id: UUID
    let stageTitle: String
    let vaccines: [String]
    
    init(id: UUID = UUID(), stageTitle: String, vaccines: [String]) {
        self.id = id
        self.stageTitle = stageTitle
        self.vaccines = vaccines
    }
}

class VaccineManager {
    static let shared = VaccineManager()
    private var selectedVaccineDict: [String: Bool] = [:]
    private var cachedVaccineStages: [VaccineStage] = []
    private var isLoading = false
    
    // Keep the static data as fallback
    private let fallbackVaccineData: [VaccineStage] = [
        // Birth to 12 months
        VaccineStage(stageTitle: "Birth", vaccines: ["Hepatitis B (Dose 1)"]),
        VaccineStage(stageTitle: "6 weeks", vaccines: ["DTaP (Dose 1)", "Hib (Dose 1)", "Polio (Dose 1)", "Hepatitis B (Dose 2)"]),
        VaccineStage(stageTitle: "10 weeks", vaccines: ["DTaP (Dose 2)", "Hib (Dose 2)", "Rotavirus (Dose 1)", "Pneumococcal (Dose 1)"]),
        VaccineStage(stageTitle: "14 weeks", vaccines: ["DTaP (Dose 3)", "Hib (Dose 3)", "Polio (Dose 3)", "Rotavirus (Dose 2)", "Pneumococcal (Dose 2)"]),
        VaccineStage(stageTitle: "6 Months", vaccines: ["Hepatitis B (Dose 3)", "Influenza (Annual)"]),
        VaccineStage(stageTitle: "9 months", vaccines: ["MMR (Dose 1)"]),
        VaccineStage(stageTitle: "12 months", vaccines: ["Hepatitis A (Dose 1)", "Varicella (Dose 1)"]),
        
        // 1-3 years
        VaccineStage(stageTitle: "15 months", vaccines: [
            "DTaP (Dose 4)",
            "Hib (Dose 4)",
            "MMR (Dose 2)",
            "Varicella (Dose 2)",
            "Pneumococcal (Dose 4)"
        ]),
        VaccineStage(stageTitle: "18 months", vaccines: [
            "Hepatitis A (Dose 2)",
            "DTaP (Dose 4 if not given at 15 months)"
        ]),
        VaccineStage(stageTitle: "2 years", vaccines: [
            "Influenza (Annual)",
            "Pneumococcal polysaccharide (if at risk)"
        ]),
        VaccineStage(stageTitle: "2.5 years", vaccines: [
            "Influenza (Annual)"
        ]),
        VaccineStage(stageTitle: "3 years", vaccines: [
            "Influenza (Annual)",
            "DTaP (Dose 5)",
            "Polio (Dose 4)"
        ])
    ]
    
    var vaccineData: [VaccineStage] {
        return cachedVaccineStages.isEmpty ? fallbackVaccineData : cachedVaccineStages
    }
    
    private init() {
        // Load vaccine data when the manager is initialized
        Task {
            await loadVaccineData()
        }
    }
    
    // Fetch vaccine data from Supabase
    func loadVaccineData() async {
        if isLoading { return }
        isLoading = true
        
        do {
            // Get vaccines from Supabase
            let vaccines = try await SupabaseVaccineManager.shared.fetchAllVaccines()
            
            // Group vaccines by stages based on startWeek (this is an example grouping logic)
            var stageMap: [String: [String]] = [:]
            
            for vaccine in vaccines {
                let weeks = vaccine.startWeek
                let stageTitle: String
                
                // Determine stage based on weeks
                if weeks == 0 {
                    stageTitle = "Birth"
                } else if weeks <= 6 {
                    stageTitle = "6 weeks"
                } else if weeks <= 10 {
                    stageTitle = "10 weeks"
                } else if weeks <= 14 {
                    stageTitle = "14 weeks"
                } else if weeks <= 26 {
                    stageTitle = "6 Months"
                } else if weeks <= 39 {
                    stageTitle = "9 months"
                } else if weeks <= 52 {
                    stageTitle = "12 months"
                } else if weeks <= 65 {
                    stageTitle = "15 months"
                } else if weeks <= 78 {
                    stageTitle = "18 months"
                } else if weeks <= 104 {
                    stageTitle = "2 years"
                } else if weeks <= 130 {
                    stageTitle = "2.5 years"
                } else {
                    stageTitle = "3 years"
                }
                
                // Add to stage map
                if stageMap[stageTitle] == nil {
                    stageMap[stageTitle] = []
                }
                stageMap[stageTitle]?.append(vaccine.name)
            }
            
            // Convert map to array of stages
            var stages: [VaccineStage] = []
            for (stageTitle, vaccineNames) in stageMap {
                stages.append(VaccineStage(stageTitle: stageTitle, vaccines: vaccineNames))
            }
            
            // Sort stages by approximate week
            stages.sort { (stage1, stage2) -> Bool in
                let weekOrder: [String: Int] = [
                    "Birth": 0,
                    "6 weeks": 6,
                    "10 weeks": 10,
                    "14 weeks": 14,
                    "6 Months": 26,
                    "9 months": 39,
                    "12 months": 52,
                    "15 months": 65,
                    "18 months": 78,
                    "2 years": 104,
                    "2.5 years": 130,
                    "3 years": 156
                ]
                
                return (weekOrder[stage1.stageTitle] ?? 999) < (weekOrder[stage2.stageTitle] ?? 999)
            }
            
            // Update cache on main thread
            await MainActor.run {
                self.cachedVaccineStages = stages
                print("✅ Successfully loaded \(stages.count) vaccine stages from Supabase")
            }
        } catch {
            print("❌ Error loading vaccines from Supabase: \(error)")
            // Keep using fallback data
        }
        
        isLoading = false
    }
    
    // Fetch all vaccines (not grouped by stage)
    func fetchAllVaccines() async -> [String] {
        do {
            let vaccines = try await SupabaseVaccineManager.shared.fetchAllVaccines()
            return vaccines.map { $0.name }
        } catch {
            print("❌ Error fetching all vaccines: \(error)")
            // Return all vaccines from fallback data
            return fallbackVaccineData.flatMap { $0.vaccines }
        }
    }
    
    func selectVaccine(_ vaccine: String) {
        selectedVaccineDict[vaccine] = true
    }
    
    func unselectVaccine(_ vaccine: String) {
        selectedVaccineDict[vaccine] = false
    }
    
    func getSelectedVaccines() -> [String] {
        return selectedVaccineDict.filter { $0.value }.map { $0.key }
    }
}
