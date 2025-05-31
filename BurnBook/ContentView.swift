import SwiftUI
import Combine

struct LoadingView: View {
    let message: String
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.orange.opacity(0.15), .red.opacity(0.15)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                    .scaleEffect(1.5)
                Text(message)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        
    }
        
}

struct CustomSegmentedPicker: View {
    @Binding var selection: RoastCategory
    @State private var segmentWidths: [CGFloat] = Array(repeating: 0, count: RoastCategory.allCases.count)

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(Array(RoastCategory.allCases.enumerated()), id: \.element) { index, category in
                    Text(category.rawValue)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(selection == category ? .white : .gray)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background {
                            if selection == category {
                                LinearGradient(colors: [.orange, .red],
                                             startPoint: .leading,
                                             endPoint: .trailing)
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selection = category
                            }
                        }
                        .background(
                            GeometryReader { segmentGeometry -> Color in
                                DispatchQueue.main.async {
                                }
                                return Color.clear
                            }
                        )
                }
            }
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        updateSelection(at: value.location, in: geometry.size)
                    }
            )
        }
        .frame(height: 44)
        .padding(.horizontal, 30)
    }

    private func updateSelection(at location: CGPoint, in size: CGSize) {
        let totalWidth = size.width
        let segmentCount = RoastCategory.allCases.count
        guard segmentCount > 0 else { return }

        let singleSegmentWidth = totalWidth / CGFloat(segmentCount)
        
        var cumulativeWidth: CGFloat = 0
        for (_, category) in RoastCategory.allCases.enumerated() {
            cumulativeWidth += singleSegmentWidth
            if location.x < cumulativeWidth {
                if selection != category {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = category
                    }
                }
                break
            }
        }
    }
}

struct ContentView: View {
    
    @State private var text: String = ""
    @StateObject var evaluator = LLMEvaluator()
    @State private var navigateToResult = false
    
    @State private var isModelReady = false
    @State private var loadingMessage = "Warming up the Burns..."
    @State private var selectedCategory: RoastCategory = .auto
    @State private var roastSettings = RoastSettings()
    @State private var showSettings = false
    @StateObject private var roastCollection = RoastCollection()
    @State private var showCollection = false
    
    private func validateInput(_ string: String) -> Bool {
        let letterCharacterSet = CharacterSet.letters
        let stringCharacterSet = CharacterSet(charactersIn: string)
        return stringCharacterSet.isSubset(of: letterCharacterSet)
    }
    
    private func calculateAngle() -> Double {
        let remainingCharacters = 45 - text.count
        return Double(remainingCharacters) * (360.0 / 45.0)
    }
    
    private func calculateProgress() -> Double {
        let remainingCharacters = 45 - text.count
        return Double(remainingCharacters) / 45.0
    }
    
    private var remainingCharacters: Int {
        return 45 - text.count
    }
    
    private var borderWidth: CGFloat {
        let remainingCharacters = 45 - text.count
        return CGFloat(remainingCharacters) / 10
    }
    
    private var wittyPlaceholder: String {
        switch selectedCategory {
        case .auto:
            return "Who's getting burned?"
        case .person:
            return "Name the victim..."
        case .object:
            return "What's on the chopping block?"
        }
    }
    
    private var segmentGradient: LinearGradient {
        LinearGradient(colors: [.orange, .red],
                       startPoint: .leading,
                       endPoint: .trailing)
    }
    
    var body: some View {
        makeContentView()
            .onAppear {
                if !isModelReady {
                    Task {
                        loadingMessage = "Downloading AI Model (this might take a moment on first launch)..."
                        let setupSuccess = await evaluator.setupModel()
                        if setupSuccess {
                            isModelReady = true
                        } else {
                            loadingMessage = "Failed to set up AI Model. \(evaluator.output) Please restart the app or check your connection."
                        }
                    }
                }
            }
            .onChange(of: navigateToResult) { oldValue, newValue in
                if oldValue == true && newValue == false {
                    text = ""
                }
            }
    }
    
    @ViewBuilder
    private func makeContentView() -> some View {
        if !isModelReady {
            LoadingView(message: loadingMessage)
        } else {
            NavigationStack {
                ZStack {
                    LinearGradient(colors: [.orange.opacity(0.15), .red.opacity(0.15)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                    
                    VStack(spacing: 30) {
                        CustomSegmentedPicker(selection: $selectedCategory)
                            .padding(.top, 60)
                        
                        Spacer()
                        
                        Text("Burn Book")
                            .font(.system(size: 52, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.orange, .red],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                            .shadow(radius: 2)
                        
                        VStack(spacing: 0) {
                            TextField(wittyPlaceholder, text: $text)
                                .font(.title3)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .trim(from: 0, to: Double(45 - text.count) / 45.0)
                                        .stroke(
                                            LinearGradient(colors: [.orange, .red],
                                                           startPoint: .leading,
                                                           endPoint: .trailing),
                                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                                        )
                                )
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                                .onChange(of: text, initial: false) { oldValue, newValue in
                                    if oldValue.count >= 45 && newValue.count > oldValue.count {
                                        text = oldValue
                                        return
                                    }
                                    text = newValue.filter { $0.isLetter || $0.isWhitespace }
                                }
                                .animation(.smooth, value: text)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 150)
                    .padding(.horizontal, 30)
                    
                    VStack{
                        Spacer()
                        Button(action: {
                            self.navigateToResult = true
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
                                    .opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                                )
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                        }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                    
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 10) {
                            Button(action: {
                                showCollection = true
                            }) {
                                Image(systemName: "bookmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(
                                        LinearGradient(colors: [.orange, .red],
                                                       startPoint: .leading,
                                                       endPoint: .trailing)
                                    )
                                    .frame(width: 40, height: 40)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                            }
                            
                            Button(action: {
                                showSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(
                                        LinearGradient(colors: [.orange, .red],
                                                       startPoint: .leading,
                                                       endPoint: .trailing)
                                    )
                                    .frame(width: 40, height: 40)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(isPresented: $navigateToResult) {
                    let systemPrompt = SystemPromptFactory.getPrompt(for: selectedCategory, itemName: text, settings: roastSettings)
                    ResultView(nameToRoast: text, evaluator: evaluator, systemPromptForRoast: systemPrompt, roastCollection: roastCollection, settings: roastSettings)
                        .navigationBarBackButtonHidden()
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView(settings: $roastSettings)
                }
                .sheet(isPresented: $showCollection) {
                    CollectionView(roastCollection: roastCollection, settings: roastSettings)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
    }
    
    // Existing onAppear and onChange remain the same
}

#Preview {
    ContentView()
}
