import SwiftUI
import CoreHaptics

struct ContentView: View {
    
    @State private var text: String = ""
    @State private var engine: CHHapticEngine?
    
    
    private func validateInput(_ string: String) -> Bool {
        let letterCharacterSet = CharacterSet.letters
        let stringCharacterSet = CharacterSet(charactersIn: string)
        return stringCharacterSet.isSubset(of: letterCharacterSet)
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }

    func complexSuccess() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }

    var body: some View {
        
        
        ZStack {
            // Background gradient
            LinearGradient(colors: [.orange.opacity(0.15), .red.opacity(0.15)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("Burn Book")
                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .red],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing)
                    )
                    .shadow(radius: 2)
                    .padding(.top, 60)
               
                // Input field
                TextField("Who's turn is it?", text: $text)
                    
                    .font(.title3)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    .onChange(of: text, initial: false) { oldValue, newValue in
                        // Limit to 45 characters and validate for letters only
                        if newValue.count > 45 {
                            text = String(newValue.prefix(45))
                        }
                        
                        // Remove any non-letter characters
                        text = newValue.filter { $0.isLetter }
                    }
                
                Spacer()
                
                
                
                
                
            }
            .padding(.bottom, 150)
            .padding(.horizontal, 30)
            
            
            VStack{
                Spacer()
                // Roast button
                Button(action: {
                    complexSuccess()
                }) {
                    Text("Roast It")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(colors: [.orange, .red],
                                         startPoint: .leading,
                                         endPoint: .trailing)
                                .opacity(text.isEmpty ? 0.5 : 1)
                        )
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                }
                .disabled(text.isEmpty)
                .padding(.top, 20)
            }
            .padding(.horizontal, 30)

        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            prepareHaptics()
        }
    }
}

#Preview {
    ContentView()
}
