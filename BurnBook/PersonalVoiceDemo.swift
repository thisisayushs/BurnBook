//
//  PersonalVoiceDemo.swift
//  BurnBook
//
//  Created by Ayush Singh on 6/1/25.
//

import SwiftUI
import AVFoundation

struct PersonalVoiceDemo: View {
    
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var personalVoices: [AVSpeechSynthesisVoice] = []
    
    // Requests authorization
    func fetchPersonalVoices() async {
        AVSpeechSynthesizer.requestPersonalVoiceAuthorization() { status in
            if status == .authorized {
                personalVoices = AVSpeechSynthesisVoice.speechVoices().filter {
                    $0.voiceTraits.contains(.isPersonalVoice)
                }
            }
        }
    }
    
    // Speaks
    func speakUtterance(string: String) {
        let utterance = AVSpeechUtterance(string: string)
        if let voice = personalVoices.first {
            utterance.voice = voice
            synthesizer.speak(utterance)
            
        }
    }
    
    
    
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Request Access") {
                Task {
                    await fetchPersonalVoices()
                }
            }
            
            Button("Speak") {
                speakUtterance(string: "Hello. This is a test for personal voice speech synthesis.")
            }
        }
    }
}

#Preview {
    PersonalVoiceDemo()
}
