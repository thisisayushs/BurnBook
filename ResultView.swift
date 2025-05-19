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
    
    @State private var displayRoast: String = "Roasting..." // CHANGED: Simplified state for displaying the roast
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.orange.opacity(0.15), .red.opacity(0.15)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack {
                ZStack(alignment: .topTrailing) { // ADD: Alignment for the reload button
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .foregroundStyle(.white)
                        .frame(height: 500)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                        .padding()
                    
                    // CHANGE: Display the displayRoast state
                    Text(displayRoast)
                        .italic()
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center) // ADD: for better text flow
                        .padding(EdgeInsets(top: 60, leading: 40, bottom: 40, trailing: 40)) // Adjust padding
                        .frame(maxWidth: .infinity, maxHeight: 500, alignment: .center) // Ensure text is centered
                        .foregroundStyle(LinearGradient(colors: [.orange, .red],
                                                        startPoint: .leading,
                                                        endPoint: .trailing))
                        .animation(.easeInOut, value: displayRoast)
                    
                    // ADD: Reload button
                    Button(action: {
                        Task {
                            displayRoast = "Roasting \(nameToRoast) again..." // Update loading message
                            await evaluator.generate(prompt: nameToRoast)
                            // The .onChange(of: evaluator.output) will handle updating displayRoast
                        }
                    }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title)
                            .foregroundStyle(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                            .padding(30) // Increased padding for easier tap
                    }
                    .padding(.trailing, 15) // Adjust positioning from the card edge
                    .disabled(evaluator.running) // Disable while a generation is in progress
                        
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
            // Initial roast generation
            if displayRoast == "Roasting..." { // Only generate if it's the initial load
                displayRoast = "Roasting \(nameToRoast)..."
                await evaluator.generate(prompt: nameToRoast)
                // The .onChange below will handle the result
            }
        }
        .onChange(of: evaluator.output) { _, newOutput in
            if !evaluator.running { // Only update if not currently generating a new one
                if !newOutput.isEmpty && !newOutput.contains("Error:") {
                    self.displayRoast = newOutput
                } else if newOutput.contains("Error:") {
                    self.displayRoast = newOutput // Show the error
                } else if newOutput.isEmpty && displayRoast.starts(with: "Roasting") { 
                    // Handle case where output is empty after generation attempt
                    self.displayRoast = "Couldn't think of a roast for \(nameToRoast)!"
                }
            }
        }
        .onChange(of: evaluator.running) { _, isRunning in
            if isRunning && !displayRoast.starts(with: "Roasting") {
                // If a new generation starts (e.g. reload) and current displayRoast isn't a loading message
                displayRoast = "Roasting \(nameToRoast) again..."
            }
        }
    }
}

#Preview {
    ResultView(nameToRoast: "Test Name", evaluator: LLMEvaluator())
}