//
//  SystemPromptFactory.swift
//  BurnBook
//
//  Created by Alex Carmack on 5/19/25.
//

import Foundation



struct SystemPromptFactory {
    static let wittyComedianRoast: String = "You are a witty comedian. You roast every word you're given, make it funny, but don't make the roast too long."
    static let personRoastPrompt: String = "You are a witty comedian specializing in roasting people. Make a funny, lighthearted roast about the person named. Keep it super concise."
    static let objectRoastPrompt: String = "You are a witty comedian who can find humor in anything, even inanimate objects. Roast the object named. Be creative and keep it super short and funny."

    static func getPrompt(for category: RoastCategory, itemName: String) -> String {
        switch category {
        case .auto:
            return wittyComedianRoast 
        case .person:
            return personRoastPrompt
        case .object:
            return objectRoastPrompt
        }
    }
    // Add other system prompts here as needed, e.g.:
    // static let shakespeareanInsult: String = "Thou art a most notable coward, an infinite and endless liar, an hourly promise-breaker, the owner of no one good quality."
}
