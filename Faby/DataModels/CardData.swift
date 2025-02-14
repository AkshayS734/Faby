//
//  CardData.swift
//  Faby
//
//  Created by Batch - 1 on 16/01/25.
//

// CardData.swift
// CardData.swift
import Foundation

struct Card {
    let title: String
    let subtitle: String
}

class CardDataProvider {
    static let shared = CardDataProvider()

    private init() {}

    // Updated card data as an array of `Card` objects
    let cardData: [Card] = [
        Card(title: "Sleep Solutions", subtitle: "Bedtime Routine, Sleep Regressions, Night Waking, etc."),
        Card(title: "Healthy Nutrition", subtitle: "Meal Planning, Picky Eaters, Food Introduction, Food Allergies, etc."),
        Card(title: "Managing Tantrums", subtitle: "Emotional Understanding, Calming Techniques, Boundaries, etc."),
        Card(title: "Speech Development", subtitle: "Early Communication, Speech Delays, Storytelling, Songs & Rhymes, etc."),
        Card(title: "Learning Activities", subtitle: "Play-Based Learning, Motor Skills, Literacy Activities, Exploration, etc."),
        Card(title: "Home Safety", subtitle: "Childproofing, Electrical Safety, Safe Spaces, First Aid, etc."),
        Card(title: "Social Skills", subtitle: "Sharing & Turn-Taking, Empathy, Peer Interactions, Conflict Management, etc."),
        Card(title: "Parental Guidance", subtitle: "Support Networks, Stress Management, Time Management, etc."),
        Card(title: "Special Needs Support", subtitle: "Special Needs Programs, Individualized Support, etc."),
        Card(title: "Social Skills", subtitle: "Sharing & Turn-Taking, Empathy, Peer Interactions, Conflict Management, etc. ")
        
    ]
}
