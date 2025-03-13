import SwiftUI

struct ContentView: View {
    
    @State private var text: String = ""
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
                Spacer()
                // Input field
                TextField("Who's turn is it?", text: $text)
                    .font(.system(size: 22, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                
                Spacer()
                Spacer()
                // Roast button
                Button(action: {
                    
                }) {
                    Text("Roast It!")
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
                .padding(.top, 20)
                
                
                
            }
            .padding(.horizontal, 30)
        }
       
    }
}

#Preview {
    ContentView()
}
