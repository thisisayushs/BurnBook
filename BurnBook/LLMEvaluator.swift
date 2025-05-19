//
//  LLMEvaluator.swift
//  BurnBook
//
//  Created by Ayush Singh on 5/19/25.
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
    
    func loadModel() async throws {
        guard modelContainer == nil else { return }
        
        MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)
        
        modelContainer = try await LLMModelFactory.shared.loadContainer(
            configuration: modelConfig
        ) { progress in
            print("Downloading model: \(Int(progress.fractionCompleted * 100))%")
        }
    }
    
    func setupModel() async -> Bool {
        guard !running else {
            // Another operation is in progress
            return false
        }
        running = true
        var success = false
        
        do {
            // output = "Initializing model..." // You can set this if you want intermediate UI updates
            try await loadModel()

            // output = "Testing model..."
            // Perform a minimal test generation to ensure the model is responsive
            let testResult = try await modelContainer!.perform { context in
                let input = try await context.processor.prepare(
                    input: .init(messages: [
                        ["role": "system", "content": "You are a health check. Respond with OK if operational."],
                        ["role": "user", "content": "status_check"]
                    ])
                )

                // Use very restrictive parameters for this test
                return try MLXLMCommon.generate(
                    input: input,
                    parameters: GenerateParameters(temperature: 0.1), // Short and quick
                    context: context
                ) { tokens in
                    // Stop early, we just need a small response
                    return tokens.count >= 2 ? .stop : .more
                }
            }
            
            if !testResult.output.isEmpty && !testResult.output.lowercased().contains("error") {
                print("Model setup test successful. Output: \(testResult.output)")
                success = true
                // Clear any test output from the main published variable if it was set
                // If output was modified by test, reset it or set to a neutral "Ready."
                // self.output = "Model ready." // Optional: depends on desired UI state post-setup
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

    func generate(prompt: String, systemPrompt: String = "You are a witty comedian. You roast every word you're given, make it funny, but don't make the roast too long.") async {
            guard !running else { return }
            running = true
            output = "Generating..."

            do {
                try await loadModel()

                let result = try await modelContainer!.perform { context in
                    let input = try await context.processor.prepare(
                        input: .init(messages: [
                            ["role": "system", "content": systemPrompt],
                            ["role": "user", "content": prompt]
                        ])
                    )
                    // Define parameters for generation here
                    let generateParams = GenerateParameters(temperature: 0.7)

                    return try MLXLMCommon.generate(
                        input: input,
                        parameters: generateParams,
                        context: context
                    ) { tokens in
                        let partial = context.tokenizer.decode(tokens: tokens)
                        Task { @MainActor in self.output = partial }
                        // Consider a reasonable max token count for roasts
                        return tokens.count >= 200 ? .stop : .more
                    }
                }

                output = result.output
            } catch {
                output = "Error: \(error.localizedDescription)"
            }

            running = false
        }
    }
