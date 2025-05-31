//
//  RoastSettings.swift
//  BurnBook
//
//  Created by Ayush Kumar Singh on 5/20/25.
//

import Foundation

enum SpeechAccent: String, CaseIterable, Identifiable {
    case american = "American"
    case british = "British"
    case australian = "Australian"
    case irish = "Irish"
    case southAfrican = "South African"
    
    var id: String { self.rawValue }
    
    var voiceLanguage: String {
        switch self {
        case .american: return "en-US"
        case .british: return "en-GB"
        case .australian: return "en-AU"
        case .irish: return "en-IE"
        case .southAfrican: return "en-ZA"
        }
    }
}

struct RoastSettings {
    var intensity: RoastIntensity = .homicidal
    var allowsPolitics: Bool = false
    var allowsProfanity: Bool = false
    var speechAccent: SpeechAccent = .american
    var speechSpeed: Double = 0.5 
    var speechPitch: Double = 1.0 
}
