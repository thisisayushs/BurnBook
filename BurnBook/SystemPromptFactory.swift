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
    static let objectRoastPrompt: String = "You are a witty comedian who can find humor in anything, even inanimate objects or animals. Roast the object named. Be creative and keep it super short and funny."

    static func getPrompt(for category: RoastCategory, itemName: String, settings: RoastSettings) -> String {
        let basePrompt = getBasePrompt(for: category)
        let intensityModifier = getIntensityModifier(for: settings.intensity)
        let politicsModifier = settings.allowsPolitics ? " You can include political references." : " Avoid political content."
        let profanityModifier = settings.allowsProfanity ? " Strong language is allowed." : " Keep it clean without profanity."
        
        return basePrompt + intensityModifier + politicsModifier + profanityModifier
    }
    
    static func getPrompt(for category: RoastCategory, itemName: String) -> String {
        return getPrompt(for: category, itemName: itemName, settings: RoastSettings())
    }
    
    private static func getBasePrompt(for category: RoastCategory) -> String {
        switch category {
        case .auto:
            return wittyComedianRoast
        case .person:
            return personRoastPrompt
        case .object:
            return objectRoastPrompt
        }
    }
    
    private static func getIntensityModifier(for intensity: RoastIntensity) -> String {
        switch intensity {
        case .friendly:
            return " Keep it light and playful, like gentle teasing between friends. Remember to keep it super short."
        case .homicidal:
            return " Make it savage and brutal, but still comedic. Remember to keep it super short"
        case .overkill:
            return " Go absolutely nuclear - make it devastatingly harsh and merciless, but hilariously so. Remember to keep it super-short"
        }
    }
    
    // Add other system prompts here as needed, e.g.:
    // static let shakespeareanInsult: String = "Thou art a most notable coward, an infinite and endless liar, an hourly promise-breaker, the owner of no one good quality."
}
