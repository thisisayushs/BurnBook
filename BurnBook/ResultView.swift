//
//  ResultView.swift
//  BurnBook
//
//  Created by Ayush Kumar Singh on 13/03/25.
//

import SwiftUI

struct ResultView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let nameToRoast: String
    @ObservedObject var evaluator: LLMEvaluator 
    let systemPromptForRoast: String
    
    @State private var currentRoast: String = "Roasting..."
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.orange.opacity(0.15), .red.opacity(0.15)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack {
                ZStack(alignment: .topTrailing) { // Keep existing alignment for potential future buttons
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .foregroundStyle(.white)
                        .frame(minHeight: 300, idealHeight: 400, maxHeight: 500) // Adjust height constraints
                        .shadow(color: .black.opacity(0.1), radius: 5)
                        .padding()
                    
                    // Simplified logic for displayRoast
                    Text(evaluator.running && currentRoast == "Roasting..." ? "Roasting \(nameToRoast)..." : currentRoast)
                        .italic()
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 40, leading: 40, bottom: 40, trailing: 40))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Ensure text is centered within available space
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
                        // Share functionality (placeholder)
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
                    .padding(.horizontal)
                    
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
                // Logic for setting currentRoast from evaluator.output will be handled by .onChange
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
            } else if evaluator.running && newOutput.starts(with: "Generating...") || newOutput.isEmpty {
                 // If evaluator is running and output is cleared or set to "Generating..."
                 // currentRoast can remain "Roasting..." or be updated to a generic loading
                 // This part depends on how LLMEvaluator sets its output during progressive generation
            } else if evaluator.running && !newOutput.isEmpty {
                // If LLMEvaluator provides progressive output
                self.currentRoast = newOutput
            }
        }
    }
}

#Preview {
    ResultView(nameToRoast: "Test Name", evaluator: LLMEvaluator(), systemPromptForRoast: SystemPromptFactory.wittyComedianRoast)
}
