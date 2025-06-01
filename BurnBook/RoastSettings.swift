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

struct RoastSettings {
    var intensity: RoastIntensity = .homicidal
    var allowsPolitics: Bool = false
    var allowsProfanity: Bool = false
    var speechAccent: SpeechAccent = .american
    var speechSpeed: Double = 0.5
    var speechPitch: Double = 1.0
}
