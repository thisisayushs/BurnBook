//
//  ResultView.swift
//  BurnBook
//
//  Created by Ayush Kumar Singh on 13/03/25.
//

import SwiftUI
import CoreHaptics
import AVFoundation

// MARK: - Safe wrapper for sharing
private struct ShareImage: Identifiable {
    let id = UUID()
    let url: URL            // now share by file-URL so filename is honoured
}

struct ShareCard: View {
    let roastText: String
    let titleText: String
    let forcedColorScheme: ColorScheme

    var body: some View {
        ZStack {
            if forcedColorScheme == .dark {
                Color.black
            } else {
                Color.white
            }
            LinearGradient(colors: [.orange.opacity(0.15), .red.opacity(0.15)],
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
            
            VStack(spacing: 20) {
                Text(titleText)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .red],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing)
                    )
                
                Text(roastText)
                    .italic()
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .red],
                                     startPoint: .leading,
                                     endPoint: .trailing)
                    )
                    .padding(.horizontal, 20)
                
                Text("Burn Book")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.top, 10)
            }
            .frame(width: 300)
            .padding(40)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 5)
        }
       
        .frame(width: 400, height: 600)
        .preferredColorScheme(forcedColorScheme)
    }
}

struct ResultView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var appColorScheme

    let nameToRoast: String
    @ObservedObject var evaluator: LLMEvaluator
    let systemPromptForRoast: String
    let roastCollection: RoastCollection
    let settings: RoastSettings
    
    @State private var currentRoast: String = "Roasting..."
    @State private var shareItem: ShareImage?          // drives the sheet
    @State private var isBookmarked = false
    @State private var hapticEngine: CHHapticEngine?
    @State private var lastOutputLength = 0
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var isSpeaking = false
    @State private var speechDelegate: SpeechDelegate?

    private func generateShareImage() -> UIImage {
        let shareCard = ShareCard(roastText: currentRoast, titleText: nameToRoast, forcedColorScheme: appColorScheme)
        let renderer = ImageRenderer(content: shareCard)
        renderer.scale = 3.0
        renderer.isOpaque = true
        
        return renderer.uiImage ?? UIImage()
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }
    
    private func playTypingHaptic() {
        guard let hapticEngine = hapticEngine else { return }
        
        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
            
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }
    
    private func speakRoast() {
        if isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
        } else {
            let utterance = AVSpeechUtterance(string: currentRoast)
            // Accent – fall back to en-US if the requested voice isn’t present
            if let accentVoice = AVSpeechSynthesisVoice(language: settings.speechAccent.voiceLanguage) {
                utterance.voice = accentVoice
            } else {
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            }
            
            // Rate – map 0‥1 slider-percent onto the legal min‥max range
            let minRate = AVSpeechUtteranceMinimumSpeechRate   // ≈ 0.0
            let maxRate = AVSpeechUtteranceMaximumSpeechRate   // ≈ 1.0
            utterance.rate = minRate + (maxRate - minRate) * Float(settings.speechSpeed)
            
            // Pitch (0.5‥2.0) comes straight from settings
            utterance.pitchMultiplier = Float(settings.speechPitch)
            
            // Volume stays constant
            utterance.volume = 0.8
            
            speechSynthesizer.speak(utterance)
            isSpeaking = true
        }
    }
    
    private func toggleBookmark() {
        isBookmarked.toggle()
        if isBookmarked && !currentRoast.starts(with: "Roasting") && !currentRoast.contains("Error:") {
            let savedRoast = SavedRoast(nameToRoast: nameToRoast, roastText: currentRoast)
            roastCollection.saveRoast(savedRoast)
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        else if !isBookmarked {
            // Find and remove the roast from collection
            if let roastToRemove = roastCollection.savedRoasts.first(where: {
                $0.nameToRoast == nameToRoast && $0.roastText == currentRoast
            }) {
                roastCollection.deleteRoast(roastToRemove)
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.orange.opacity(0.15), .red.opacity(0.15)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .foregroundStyle(.white)
                        .frame(minHeight: 300, idealHeight: 400, maxHeight: 500)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                        .padding()
                    
                    HStack(spacing: 15) {
                        Button(action: toggleBookmark) {
                            Image(systemName: isBookmarked ? "bookmark.circle.fill" : "bookmark.circle")
                                .font(.system(size: 28))
                                .foregroundStyle(
                                    isBookmarked ?
                                    LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [.gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 5)
                                .scaleEffect(isBookmarked ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isBookmarked)
                        }
                        .disabled(evaluator.running)
                        
                        Button(action: {
                            Task {
                                currentRoast = "Roasting \(nameToRoast) again..."
                                await evaluator.generate(prompt: nameToRoast, systemPrompt: systemPromptForRoast)
                            }
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(
                                    evaluator.running ?
                                    LinearGradient(colors: [.gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [.orange, .red],
                                                 startPoint: .leading,
                                                 endPoint: .trailing)
                                )
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 5)
                        }
                        .disabled(evaluator.running)
                        .scaleEffect(evaluator.running ? 0.9 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: evaluator.running)
                    }
                    .padding(35)
                    
                    VStack {
                        Text(evaluator.running && currentRoast == "Roasting..." ? "Roasting \(nameToRoast)..." : currentRoast)
                            .italic()
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(EdgeInsets(top: 40, leading: 40, bottom: 20, trailing: 40))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .foregroundStyle(LinearGradient(colors: [.orange, .red],
                                                          startPoint: .leading,
                                                          endPoint: .trailing))
                            .animation(.easeInOut, value: currentRoast)
                            .animation(.easeInOut, value: evaluator.running)
                        
                        // Speech button at bottom of card
                        Button(action: speakRoast) {
                            Image(systemName: isSpeaking ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(
                                    evaluator.running || currentRoast.starts(with: "Roasting") || currentRoast.contains("Error:") ?
                                    LinearGradient(colors: [.gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [.orange, .red],
                                                 startPoint: .leading,
                                                 endPoint: .trailing)
                                )
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 3)
                        }
                        .disabled(evaluator.running || currentRoast.starts(with: "Roasting") || currentRoast.contains("Error:"))
                        .padding(.bottom, 50)
                        .scaleEffect(isSpeaking ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSpeaking)
                    }
                }
                VStack {
                    Button(action: {
                        // 1. Render UIImage
                        let rendered = generateShareImage()
                        
                        // 2. Encode as PNG
                        guard let data = rendered.pngData() else { return }
                        
                        // 3. Build a nice filename: "<Name> Roast.png"
                        let safeName = nameToRoast
                            .replacingOccurrences(of: "/", with: "-")   // avoid illegal chars
                            .replacingOccurrences(of: ":", with: "-")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        let fileName = "\(safeName) Roast.png"
                        
                        // 4. Write to a temp file
                        let url = FileManager.default.temporaryDirectory
                            .appendingPathComponent(fileName)
                        try? data.write(to: url, options: .atomic)
                        
                        // 5. Present sheet
                        shareItem = ShareImage(url: url)
                    }) {
                        Text("Share")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.orange, .red],
                                               startPoint: .leading,
                                               endPoint: .trailing))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    }
                    .disabled(evaluator.running)
                    .padding(.horizontal)
                    .sheet(item: $shareItem) { item in
                        ShareSheet(items: [item.url])
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Try Another")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                LinearGradient(colors: [.orange, .red],
                                             startPoint: .leading,
                                             endPoint: .trailing)
                            )
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    }
                    .padding()
                }
                .padding()
            }
        }
        .task {
            if currentRoast == "Roasting..." {
                await evaluator.generate(prompt: nameToRoast, systemPrompt: systemPromptForRoast)
            }
        }
        .onAppear {
            prepareHaptics()
            speechDelegate = SpeechDelegate(isSpeaking: $isSpeaking)
            speechSynthesizer.delegate = speechDelegate
        }
        .onChange(of: evaluator.output) { _, newOutput in
            if !evaluator.running {
                if !newOutput.isEmpty && !newOutput.contains("Error:") {
                    self.currentRoast = newOutput
                } else if newOutput.contains("Error:") {
                    self.currentRoast = newOutput
                } else if newOutput.isEmpty && (currentRoast.starts(with: "Roasting") || currentRoast.isEmpty) {
                    self.currentRoast = "Couldn't think of a roast for \(nameToRoast)!"
                }
            } else if evaluator.running && !newOutput.isEmpty {
                self.currentRoast = newOutput
                if newOutput.count > lastOutputLength &&  !newOutput.starts(with: "Roasting") {
                    playTypingHaptic()
                }
                lastOutputLength = newOutput.count
            }
        }
    }
}

private class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    @Binding var isSpeaking: Bool
    
    init(isSpeaking: Binding<Bool>) {
        self._isSpeaking = isSpeaking
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        var shareItems: [Any] = []
        for item in items {
            if let image = item as? UIImage {
                // Convert UIImage to PNG data for better sharing compatibility
                if let imageData = image.pngData() {
                    shareItems.append(imageData)
                } else {
                    shareItems.append(item)
                }
            } else if let url = item as? URL {
                shareItems.append(url)
            } else {
                shareItems.append(item)
            }
        }
        
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .openInIBooks,
            .postToVimeo,
            .postToWeibo,
            .postToFlickr,
            .postToTencentWeibo
        ]
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ResultView(nameToRoast: "Test Name", evaluator: LLMEvaluator(), systemPromptForRoast: SystemPromptFactory.wittyComedianRoast, roastCollection: RoastCollection(), settings: RoastSettings())
}
