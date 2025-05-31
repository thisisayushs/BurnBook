//
//  LLMEvaluator.swift
//  BurnBook
//
//  Created by Ayush Kumar Singh on 5/19/25.
//

import MLX
import MLXLLM
import MLXLMCommon
import MLXRandom
import Foundation

@MainActor
class LLMEvaluator: ObservableObject {
    @Published var output = ""
    @Published var running = false
    
    private let modelConfig = ModelRegistry.llama3_2_3B_4bit
    private var modelContainer: ModelContainer? = nil

    private var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    func loadModel() async throws {
        if isPreview { return }
        
        guard modelContainer == nil else { return }
        
        MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)
        
        modelContainer = try await LLMModelFactory.shared.loadContainer(
            configuration: modelConfig
        ) { progress in
            print("Downloading model: \(Int(progress.fractionCompleted * 100))%")
        }
    }
    
    func setupModel() async -> Bool {
        if isPreview {
            self.output = "Preview: Model is ready for roasting!"
            self.running = false
            return true 
        }

        guard !running else {
            return false
        }
        running = true
        var success = false
        
        do {
            try await loadModel()

            let testResult = try await modelContainer!.perform { context in
                let input = try await context.processor.prepare(
                    input: .init(messages: [
                        ["role": "system", "content": "You are a health check. Respond with OK if operational."],
                        ["role": "user", "content": "status_check"]
                    ])
                )

                return try MLXLMCommon.generate(
                    input: input,
                    parameters: GenerateParameters(temperature: 0.1), 
                    context: context
                ) { tokens in
                    return tokens.count >= 2 ? .stop : .more
                }
            }
            
            if !testResult.output.isEmpty && !testResult.output.lowercased().contains("error") {
                print("Model setup test successful. Output: \(testResult.output)")
                success = true
            } else {
                self.output = "Error: Model test generation failed or produced empty/error output. Test output: \(testResult.output)"
                success = false
            }

        } catch {
            self.output = "Error during model setup: \(error.localizedDescription)"
            print("Detailed setup error: \(error)")
            success = false
        }
        
        running = false
        return success
    }

    func generate(prompt: String, systemPrompt: String = SystemPromptFactory.wittyComedianRoast) async {
            if isPreview {
                self.output = "This is a hilarious preview roast for '\(prompt)'! You're doing great!"
                self.running = false
                return
            }

            guard !running else { return }
            running = true
            output = "Roasting..."

            do {
                try await loadModel()

                let result = try await modelContainer!.perform { context in
                    let input = try await context.processor.prepare(
                        input: .init(messages: [
                            ["role": "system", "content": systemPrompt],
                            ["role": "user", "content": prompt]
                        ])
                    )
                    let generateParams = GenerateParameters(temperature: 0.7)

                    return try MLXLMCommon.generate(
                        input: input,
                        parameters: generateParams,
                        context: context
                    ) { tokens in
                        let partial = context.tokenizer.decode(tokens: tokens)
                        Task { @MainActor in 
                            if self.output.starts(with: "Roasting...") || self.output.isEmpty {
                                self.output = partial
                            } else {
                                self.output = partial 
                            }
                        }
                        return tokens.count >= 200 ? .stop : .more 
                    }
                }
                if !result.output.isEmpty {
                    self.output = result.output
                } else if !output.starts(with: "Error:") { 
                    self.output = "Couldn't think of a roast! Try again."
                }
            } catch {
                self.output = "Error: \(error.localizedDescription)"
            }

            running = false
        }
    }
