//
//  ResultView.swift
//  BurnBook
//
//  Created by Ayush Kumar Singh on 13/03/25.
//

import SwiftUI

struct ShareCard: View {
    let roastText: String
    let titleText: String
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.orange.opacity(0.15), .red.opacity(0.15)],
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
            
        
            
            // Main content card
            VStack(spacing: 20) {
                // Title
                Text(titleText)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .red],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing)
                    )
                
                // Roast text
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
                
                // Watermark
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
    }
}

struct ResultView: View {
    @Environment(\.dismiss) private var dismiss
    
    let nameToRoast: String
    @ObservedObject var evaluator: LLMEvaluator
    let systemPromptForRoast: String
    
    @State private var currentRoast: String = "Roasting..."
    @State private var isShareSheetPresented = false
    @State private var shareImage: UIImage?
    
    private func generateShareImage() -> UIImage {
        let shareCard = ShareCard(roastText: currentRoast, titleText: nameToRoast)
        let renderer = ImageRenderer(content: shareCard)
        renderer.scale = 3.0 // Higher resolution
        
        // Make sure background is included
        renderer.isOpaque = true
        
        return renderer.uiImage ?? UIImage()
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
                    
                    Button(action: {
                        Task {
                            currentRoast = "Roasting \(nameToRoast) again..."
                            await evaluator.generate(prompt: nameToRoast, systemPrompt: systemPromptForRoast)
                        }
                    }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(
                                LinearGradient(colors: [.orange, .red],
                                             startPoint: .leading,
                                             endPoint: .trailing)
                            )
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    }
                    .disabled(evaluator.running)
                    .padding(35)
                    
                    Text(evaluator.running && currentRoast == "Roasting..." ? "Roasting \(nameToRoast)..." : currentRoast)
                        .italic()
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 40, leading: 40, bottom: 40, trailing: 40))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .foregroundStyle(LinearGradient(colors: [.orange, .red],
                                                      startPoint: .leading,
                                                      endPoint: .trailing))
                        .animation(.easeInOut, value: currentRoast)
                        .animation(.easeInOut, value: evaluator.running)


                    // If you want a reload button, it would go here, and its action would call:
                    // await evaluator.generate(prompt: nameToRoast, systemPrompt: systemPromptForRoast)
                    // For simplicity, this example omits the explicit reload button shown in one of the earlier context files,
                    // as the primary task is to integrate the category picker.
                        
                }
                VStack {
                    Button(action: {
                        shareImage = generateShareImage()
                        if shareImage != nil {
                            isShareSheetPresented = true
                        }
                    }) {
                        Text("Share")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(LinearGradient(colors: [.orange, .red],
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
                    .sheet(isPresented: $isShareSheetPresented) {
                        if let image = shareImage {
                            ShareSheet(items: [image])
                        }
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
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ResultView(nameToRoast: "Test Name", evaluator: LLMEvaluator(), systemPromptForRoast: SystemPromptFactory.wittyComedianRoast)
}
