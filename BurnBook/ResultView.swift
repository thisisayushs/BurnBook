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
    @ObservedObject var evaluator: LLMEvaluator // Use @ObservedObject to observe changes
    
    @State private var currentRoast: String = "Roasting..."
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.orange.opacity(0.15), .red.opacity(0.15)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .foregroundStyle(.white)
                        .frame(height: 500)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                        .padding()
                    
                    Text(evaluator.running ? "Roasting..." : (currentRoast.isEmpty && !evaluator.output.isEmpty ? evaluator.output : currentRoast) )
                        .italic()
                        .fontWeight(.semibold)
                        .padding(40)
                        .foregroundStyle(LinearGradient(colors: [.orange, .red],
                                                        startPoint: .leading,
                                                        endPoint: .trailing))
                        .animation(.easeInOut, value: evaluator.running)
                        .animation(.easeInOut, value: currentRoast)
                        
                }
                VStack {
                    Button(action: {
                        
                    }) {
                        Text("Share")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(LinearGradient(colors: [.orange, .red],
                                                            startPoint: .leading,
                                                            endPoint: .trailing))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                Color.white
                                
                            )
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                        
                        
                    }.padding(.horizontal)
                    
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
            // Ensure evaluator.output is cleared or set to a loading state before generating
            // If evaluator.output holds a previous roast, it might flash briefly.
            // Consider if evaluator.output should be reset by ContentView or here.
            // For now, we'll rely on the "Roasting..." text from currentRoast.
            if currentRoast == "Roasting..." { // Only generate if not already generated or in progress
                await evaluator.generate(prompt: nameToRoast)
                // This ensures that if the view is dismissed and reopened for the same roast,
                // it doesn't re-trigger generation if evaluator.output is already populated.
                if !evaluator.output.isEmpty && !evaluator.output.contains("Error:") {
                    self.currentRoast = evaluator.output
                } else if evaluator.output.contains("Error:") {
                    self.currentRoast = evaluator.output // Show the error
                } else {
                    self.currentRoast = "Couldn't think of a roast!" // Fallback
                }
            } else if !evaluator.output.isEmpty && currentRoast != evaluator.output {
                // If there's already an output from a previous generation (e.g. due to quick re-navigation)
                // and it's different from what ResultView currently shows, update it.
                self.currentRoast = evaluator.output
            }
        }
        .onChange(of: evaluator.output) { _, newOutput in
            if !evaluator.running && !newOutput.isEmpty {
                 self.currentRoast = newOutput
            }
        }
    }
}

#Preview {
    ResultView(nameToRoast: "Test Name", evaluator: LLMEvaluator())
}
