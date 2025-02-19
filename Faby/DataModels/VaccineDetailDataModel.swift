struct Vaccine {
    let name: String
    let description: String
    let totalDoses: String
    let duration: String
    let importance: String
    let about: String
    let transmission: String
}
let vaccines: [Vaccine] = [
    Vaccine(
        name: "Influenza Vaccine",
        description: "The Influenza vaccine protects against seasonal flu.",
        totalDoses: "1 dose annually",
        duration: "1 year",
        importance: "Prevents flu and reduces complications in high-risk groups.",
        about: "The influenza virus causes seasonal flu outbreaks every year. Vaccination reduces the risk of severe illness.",
        transmission: "Spread through respiratory droplets when coughing, sneezing, or talking."
    ),
    Vaccine(
        name: "Hepatitis B Vaccine",
        description: "Protects against Hepatitis B, a serious liver infection.",
        totalDoses: "3 doses",
        duration: "6–18 months",
        importance: "Prevents severe liver infections and cancer.",
        about: "Hepatitis B is caused by the HBV virus, which can lead to chronic liver disease.",
        transmission: "Transmitted through contact with blood or bodily fluids of an infected person."
    )
]
