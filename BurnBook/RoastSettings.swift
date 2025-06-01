//
//  RoastSettings.swift
//  BurnBook
//
//  Created by Ayush Kumar Singh on 5/20/25.
//

import Foundation
import AVFoundation

enum SpeechAccent: String, CaseIterable, Identifiable {
    case american = "American"
    case british = "British"
    case australian = "Australian"
    case irish = "Irish"
    case southAfrican = "South African"
    case personal = "Personal Voice"
    
    var id: String { self.rawValue }
    
    var voiceLanguage: String {
        switch self {
        case .american: return "en-US"
        case .british: return "en-GB"
        case .australian: return "en-AU"
        case .irish: return "en-IE"
        case .southAfrican: return "en-ZA"
        case .personal: return "personal"
        }
    }
}

@MainActor
class PersonalVoiceManager: ObservableObject {
    @Published var isAuthorized = false
    @Published var personalVoices: [AVSpeechSynthesisVoice] = []
    @Published var isRequesting = false
    
    func requestPersonalVoiceAccess() async {
        isRequesting = true
        
        await withCheckedContinuation { continuation in
            AVSpeechSynthesizer.requestPersonalVoiceAuthorization { [weak self] status in
                Task { @MainActor in
                    self?.isAuthorized = (status == .authorized)
                    if status == .authorized {
                        self?.loadPersonalVoices()
                    }
                    self?.isRequesting = false
                    continuation.resume()
                }
            }
        }
    }
    
    private func loadPersonalVoices() {
        personalVoices = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.voiceTraits.contains(.isPersonalVoice)
        }
    }
    
    func getPersonalVoice() -> AVSpeechSynthesisVoice? {
        return personalVoices.first
    }
}

@MainActor
class RoastSettingsManager: ObservableObject {
    @Published var settings: RoastSettings {
        didSet {
            saveSettings()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        self.settings = Self.loadSettings()
    }
    
    private static func loadSettings() -> RoastSettings {
        let userDefaults = UserDefaults.standard
        
        let intensityRaw = userDefaults.string(forKey: "roast_intensity") ?? RoastIntensity.homicidal.rawValue
        let intensity = RoastIntensity(rawValue: intensityRaw) ?? .homicidal
        
        let allowsPolitics = userDefaults.bool(forKey: "allows_politics")
        let allowsProfanity = userDefaults.bool(forKey: "allows_profanity")
        
        let speechAccentRaw = userDefaults.string(forKey: "speech_accent") ?? SpeechAccent.american.rawValue
        let speechAccent = SpeechAccent(rawValue: speechAccentRaw) ?? .american
        
        let speechSpeed = userDefaults.object(forKey: "speech_speed") as? Double ?? 0.5
        let speechPitch = userDefaults.object(forKey: "speech_pitch") as? Double ?? 1.0
        
        return RoastSettings(
            intensity: intensity,
            allowsPolitics: allowsPolitics,
            allowsProfanity: allowsProfanity,
            speechAccent: speechAccent,
            speechSpeed: speechSpeed,
            speechPitch: speechPitch
        )
    }
    
    private func saveSettings() {
        userDefaults.set(settings.intensity.rawValue, forKey: "roast_intensity")
        userDefaults.set(settings.allowsPolitics, forKey: "allows_politics")
        userDefaults.set(settings.allowsProfanity, forKey: "allows_profanity")
        userDefaults.set(settings.speechAccent.rawValue, forKey: "speech_accent")
        userDefaults.set(settings.speechSpeed, forKey: "speech_speed")
        userDefaults.set(settings.speechPitch, forKey: "speech_pitch")
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
