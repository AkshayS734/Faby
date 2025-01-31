//
//  CardDataManager.swift
//  Toddler Talk1
//
//  Created by Vivek kumar on 30/01/25.
//
//
//  CardDataManager.swift
//  Faby
//

import Foundation

class TopicsDataManager {
    static let shared = TopicsDataManager()
    
    private init() {}

    let cardData: [Topics] = [
        Topics(title: "Sleep Solutions", subtitle: "Bedtime Routine, Sleep Regressions, Night Waking, etc."),
        Topics(title: "Healthy Nutrition", subtitle: "Meal Planning, Picky Eaters, Food Introduction, Food Allergies, etc."),
        Topics(title: "Managing Tantrums", subtitle: "Emotional Understanding, Calming Techniques, Boundaries, etc."),
        Topics(title: "Speech Development", subtitle: "Early Communication, Speech Delays, Storytelling, Songs & Rhymes, etc."),
        Topics(title: "Learning Activities", subtitle: "Play-Based Learning, Motor Skills, Literacy Activities, Exploration, etc."),
        Topics(title: "Home Safety", subtitle: "Childproofing, Electrical Safety, Safe Spaces, First Aid, etc."),
        Topics(title: "Social Skills", subtitle: "Sharing & Turn-Taking, Empathy, Peer Interactions, Conflict Management, etc."),
        Topics(title: "Parental Guidance", subtitle: "Support Networks, Stress Management, Time Management, etc."),
        Topics(title: "Special Needs Support", subtitle: "Special Needs Programs, Individualized Support, etc.")
    ]
}
