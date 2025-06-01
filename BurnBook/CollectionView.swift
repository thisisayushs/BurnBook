//
//  CollectionView.swift
//  BurnBook
//
//  Created by Ayush Kumar Singh on 13/03/25.
//

import SwiftUI
import AVFoundation

struct CollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var roastCollection: RoastCollection
    @State private var showDeleteAlert = false
    @State private var roastToDelete: SavedRoast?
    let settings: RoastSettings
    
    private var gradientColors: LinearGradient {
        LinearGradient(colors: [.orange, .red],
                      startPoint: .leading,
                      endPoint: .trailing)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.orange.opacity(0.15), .red.opacity(0.15)],
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
              
                    Text("Burn Collection")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(gradientColors)
                        .padding()
                    
                if roastCollection.savedRoasts.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray.opacity(0.5))
                        
                        Text("No Saved Burns Yet")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Text("Start collecting your favorite roasts by tapping the save button!")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(roastCollection.savedRoasts) { roast in
                                RoastCard(roast: roast, settings: settings) {
                                    roastToDelete = roast
                                    showDeleteAlert = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .enableEdgeSwipeBack()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(gradientColors)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                }
            }
        }
        .alert("Delete Roast", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let roast = roastToDelete {
                    roastCollection.deleteRoast(roast)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this roast?")
        }
    }
}

// MARK: - Safe wrapper for sharing
private struct ShareImage: Identifiable {
    let id  = UUID()
    let url: URL          // share by file-URL so filename is preserved
}

struct RoastCard: View {
    let roast: SavedRoast
    let settings: RoastSettings
    let onDelete: () -> Void
    
    @State private var isSpeaking = false
    @State private var shareItem: ShareImage?          // NEW: item-based sheet
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var speechDelegate: SpeechDelegate?     // keep delegate alive
    @StateObject private var personalVoiceManager = PersonalVoiceManager()
    @Environment(\.colorScheme) private var colorScheme
    
    private var gradientColors: LinearGradient {
        LinearGradient(colors: [.orange, .red],
                      startPoint: .leading,
                      endPoint: .trailing)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private func generateShareImage() -> UIImage {
        let shareCard = ShareCard(roastText: roast.roastText, titleText: roast.nameToRoast, forcedColorScheme: colorScheme)
        let renderer = ImageRenderer(content: shareCard)
        renderer.scale = 3.0
        renderer.isOpaque = true
        
        return renderer.uiImage ?? UIImage()
    }
    
    private func speakRoast() {
        if isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            return
        }
        
        let utterance = AVSpeechUtterance(string: roast.roastText)
        
        if settings.speechAccent == .personal {
            if let personalVoice = personalVoiceManager.getPersonalVoice() {
                utterance.voice = personalVoice
            } else {
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            }
        } else {
            if let accentVoice = AVSpeechSynthesisVoice(language: settings.speechAccent.voiceLanguage) {
                utterance.voice = accentVoice
            } else {
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            }
        }
        
        // Speed 0‥1  →  legal min‥max
        let minRate = AVSpeechUtteranceMinimumSpeechRate
        let maxRate = AVSpeechUtteranceMaximumSpeechRate
        utterance.rate = minRate + (maxRate - minRate) * Float(settings.speechSpeed)
        
        // Pitch
        utterance.pitchMultiplier = Float(settings.speechPitch)
        
        utterance.volume = 0.8
        speechSynthesizer.speak(utterance)
        isSpeaking = true
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(roast.nameToRoast)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(gradientColors)
                
                Spacer()
                
                // NEW: Speech button
                Button(action: speakRoast) {
                    Image(systemName: isSpeaking ? "speaker.slash.circle.fill" : "speaker.wave.2.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(colors: [.orange, .red],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                }
                .scaleEffect(isSpeaking ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSpeaking)
                
                // Existing share button (rewritten to use `ShareImage`)
                Button(action: {
                    let rendered = generateShareImage()
                    guard let data = rendered.pngData() else { return }
                    
                    // create a safe filename
                    let safeName = roast.nameToRoast
                        .replacingOccurrences(of: "/", with: "-")
                        .replacingOccurrences(of: ":", with: "-")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let fileName = "\(safeName) Roast.png"
                    
                    let url = FileManager.default.temporaryDirectory
                        .appendingPathComponent(fileName)
                    try? data.write(to: url, options: .atomic)
                    
                    // trigger sheet
                    shareItem = ShareImage(url: url)
                }) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(gradientColors)
                }
                
                // Existing delete button
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.red.opacity(0.7))
                }
            }
            
            Text(roast.roastText)
                .font(.body)
                .italic()
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
            Text(dateFormatter.string(from: roast.dateCreated))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        // NEW: item-based sheet avoids first-launch blank view
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.url])
        }
        .onAppear {
            // keep delegate alive so weak ref doesn’t nil-out
            speechDelegate = SpeechDelegate(isSpeaking: $isSpeaking)
            speechSynthesizer.delegate = speechDelegate
            if settings.speechAccent == .personal {
                Task {
                    await personalVoiceManager.requestPersonalVoiceAccess()
                }
            }
        }
    }
}

// Keep talking-state in sync
private class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    @Binding var isSpeaking: Bool
    
    init(isSpeaking: Binding<Bool>) {
        _isSpeaking = isSpeaking
    }
    
    func speechSynthesizer(_ s: AVSpeechSynthesizer, didFinish _: AVSpeechUtterance) {
        isSpeaking = false
    }
    func speechSynthesizer(_ s: AVSpeechSynthesizer, didCancel _: AVSpeechUtterance) {
        isSpeaking = false
    }
}

#Preview {
    CollectionView(roastCollection: RoastCollection(), settings: RoastSettings())
}
