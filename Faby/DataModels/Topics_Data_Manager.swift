//
//  TopicsDataManager.swift
//  Toddler Talk1
//
//  Created by Vivek kumar on 30/01/25.
//


import Foundation

class TopicsDataManager {
    static let shared = TopicsDataManager()
    
    private init() {}

    let cardData: [Topics] = [
        Topics(title: "Sleep Solutions", subtitle: "Bedtime Routine, Sleep Regressions, Night Waking, etc.",imageView: "Sleep_Solution"),
        Topics(title: "Healthy Nutrition", subtitle: "Meal Planning, Picky Eaters, Food Introduction, Food Allergies, etc.",imageView: "Nutrution"),
        Topics(title: "Managing Tantrums", subtitle: "Emotional Understanding, Calming Techniques, Boundaries, etc.",imageView: "Managing_Tantrum"),
        Topics(title: "Speech Development", subtitle: "Early Communication, Speech Delays, Storytelling, Songs & Rhymes, etc.",imageView: "Speech Development"),
        Topics(title: "Learning Activities", subtitle: "Play-Based Learning, Motor Skills, Literacy Activities, Exploration, etc.",imageView: "Learning Activities"),
        Topics(title: "Home Safety", subtitle: "Childproofing, Electrical Safety, Safe Spaces, First Aid, etc.",imageView: "Home Safety"),
        Topics(title: "Social Skills", subtitle: "Sharing & Turn-Taking, Empathy, Peer Interactions, Conflict Management, etc.",imageView: "Social Skills"),
        Topics(title: "Parental Guidance", subtitle: "Support Networks, Stress Management, Time Management, etc.",imageView: "Parental Guidance"),
        Topics(title: "Special Needs Support", subtitle: "Special Needs Programs, Individualized Support, etc.",imageView: "Special Support")
    ]
}
