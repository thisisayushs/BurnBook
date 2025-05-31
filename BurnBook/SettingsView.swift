//
//  SettingsView.swift
//  BurnBook
//
//  Created by Ayush Kumar Singh on 5/20/25.
//

import SwiftUI

struct CustomIntensitySlider: View {
    @Binding var value: Double
    let onChange: (Double) -> Void
    
    // MARK: - Constants
    private let trackWidth: CGFloat  = 260
    private let handleDiameter: CGFloat = 28
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("😊")
                    .font(.title2)
                    .opacity(value == 0 ? 1.0 : 0.5)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            value = 0
                            onChange(0)
                        }
                    }
                Spacer()
                Text("😈")
                    .font(.title2)
                    .opacity(value == 1 ? 1.0 : 0.5)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            value = 1
                            onChange(1)
                        }
                    }
                Spacer()
                Text("💀")
                    .font(.title2)
                    .opacity(value == 2 ? 1.0 : 0.5)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            value = 2
                            onChange(2)
                        }
                    }
            }
            
            // MARK: - Track & Handle
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: trackWidth, height: 8)
                
                // Active track
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(colors: [.orange, .red],
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )
                    .frame(width: CGFloat(value / 2.0) * trackWidth, height: 8)
                
                // Handle
                Circle()
                    .fill(Color.white)
                    .frame(width: handleDiameter, height: handleDiameter)
                    .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(colors: [.orange, .red],
                                               startPoint: .leading,
                                               endPoint: .trailing),
                                lineWidth: 3
                            )
                    )
                    // Offset ensures the C E N T E R of the handle matches the emoji position
                    .offset(x: CGFloat(value / 2.0) * trackWidth - handleDiameter / 2)
            }
            .frame(width: trackWidth)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let percent = min(max(0, gesture.location.x / trackWidth), 1)
                        let newValue = round(percent * 2)
                        if newValue != value {
                            value = newValue
                            onChange(newValue)
                        }
                    }
            )
            .onTapGesture { gesture in
                let percent = min(max(0, gesture.x / trackWidth), 1)
                let newValue = round(percent * 2)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    value = newValue
                    onChange(newValue)
                }
            }
        }
    }
}

struct CustomToggle: View {
    @Binding var isOn: Bool
    let icon: String
    let activeColor: LinearGradient
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isOn.toggle()
            }
        }) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 25)
                    .fill(isOn ? activeColor : LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 60, height: 32)
                
                // Knob
                HStack {
                    if isOn {
                        Spacer()
                    }
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
                        .overlay(
                            Image(systemName: icon)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(isOn ? activeColor : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing))
                        )
                    
                    if !isOn {
                        Spacer()
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomAccentPicker: View {
    @Binding var selectedAccent: SpeechAccent
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                ForEach(SpeechAccent.allCases.prefix(3)) { accent in
                    AccentButton(accent: accent, isSelected: selectedAccent == accent) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedAccent = accent
                        }
                    }
                }
            }
            
            HStack {
                ForEach(SpeechAccent.allCases.suffix(2)) { accent in
                    AccentButton(accent: accent, isSelected: selectedAccent == accent) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedAccent = accent
                        }
                    }
                    if accent != SpeechAccent.allCases.last {
                        Spacer()
                    }
                }
                if SpeechAccent.allCases.suffix(2).count == 1 {
                    Spacer()
                    Spacer()
                }
            }
        }
    }
}

struct AccentButton: View {
    let accent: SpeechAccent
    let isSelected: Bool
    let action: () -> Void
    
    private var flag: String {
        switch accent {
        case .american: return "🇺🇸"
        case .british: return "🇬🇧"
        case .australian: return "🇦🇺"
        case .irish: return "🇮🇪"
        case .southAfrican: return "🇿🇦"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(flag)
                    .font(.title2)
                Text(accent.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ?
                          LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing) :
                          LinearGradient(colors: [Color.gray.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                    )
            )
            .shadow(color: .black.opacity(isSelected ? 0.2 : 0.05), radius: isSelected ? 8 : 3, y: isSelected ? 4 : 1)
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomSpeedSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let emoji: (String, String)
    let onChange: (Double) -> Void
    
    // MARK: - Constants
    private let trackWidth: CGFloat  = 200
    private let handleDiameter: CGFloat = 24
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text(emoji.0)
                    .font(.title2)
                    .opacity(value == range.lowerBound ? 1.0 : 0.5)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            value = range.lowerBound
                            onChange(range.lowerBound)
                        }
                    }
                Spacer()
                Text(emoji.1)
                    .font(.title2)
                    .opacity(value == range.upperBound ? 1.0 : 0.5)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            value = range.upperBound
                            onChange(range.upperBound)
                        }
                    }
            }
            
            // MARK: - Track & Handle
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: trackWidth, height: 8)
                
                // Active track
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(colors: [.orange, .red],
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )
                    .frame(
                        width: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * trackWidth,
                        height: 8
                    )
                
                // Slider handle
                Circle()
                    .fill(Color.white)
                    .frame(width: handleDiameter, height: handleDiameter)
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(colors: [.orange, .red],
                                               startPoint: .leading,
                                               endPoint: .trailing),
                                lineWidth: 3
                            )
                    )
                    // Center‐based offset so knob aligns with percentage
                    .offset(
                        x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * trackWidth
                        - handleDiameter / 2
                    )
            }
            .frame(width: trackWidth)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let percent = min(max(0, gesture.location.x / trackWidth), 1)
                        let newValue = range.lowerBound + percent * (range.upperBound - range.lowerBound)
                        let steppedValue = round(newValue / step) * step
                        if steppedValue != value {
                            value = steppedValue
                            onChange(steppedValue)
                        }
                    }
            )
            .onTapGesture { gesture in
                let percent = min(max(0, gesture.x / trackWidth), 1)
                let newValue = range.lowerBound + percent * (range.upperBound - range.lowerBound)
                let steppedValue = round(newValue / step) * step
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    value = steppedValue
                    onChange(steppedValue)
                }
            }
            
            Text("\(Int(value * 100))%")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(
                    LinearGradient(colors: [.orange, .red],
                                 startPoint: .leading,
                                 endPoint: .trailing)
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
                )
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var settings: RoastSettings
    @State private var intensitySliderValue: Double
    @State private var speechSpeedSliderValue: Double
    @State private var speechPitchSliderValue: Double
    
    init(settings: Binding<RoastSettings>) {
        self._settings = settings
        self._intensitySliderValue = State(initialValue: settings.wrappedValue.intensity.sliderValue)
        self._speechSpeedSliderValue = State(initialValue: settings.wrappedValue.speechSpeed)
        self._speechPitchSliderValue = State(initialValue: settings.wrappedValue.speechPitch)
    }
    
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
            
            VStack(spacing: 40) {
                VStack(spacing: 15) {
                    Text("Burn Settings")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundStyle(gradientColors)
                        .shadow(radius: 2)
                    
                    Text("Customize your roasts")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                
                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 25) {
                            VStack(spacing: 20) {
                                Text("Roast Intensity")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundStyle(gradientColors)
                                
                                CustomIntensitySlider(value: $intensitySliderValue) { newValue in
                                    settings.intensity = RoastIntensity.from(sliderValue: newValue)
                                }
                                
                                Text(settings.intensity.rawValue)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(gradientColors)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.white)
                                            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                                    )
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 30)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.08), radius: 15, y: 8)
                            )
                        }
                        
                        VStack(spacing: 20) {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("🏛️")
                                            .font(.title2)
                                        Text("Politics")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundStyle(gradientColors)
                                            .fixedSize()
                                    }
                                    Text("Include political burns")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer(minLength: 10)
                                
                                CustomToggle(
                                    isOn: $settings.allowsPolitics,
                                    icon: "checkmark",
                                    activeColor: gradientColors
                                )
                            }
                            .padding(.horizontal, 25)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
                            )
                            
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("🤬")
                                            .font(.title2)
                                        Text("Profanity")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundStyle(gradientColors)
                                            .fixedSize()
                                    }
                                    Text("Allow spicy language")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer(minLength: 10)
                                
                                CustomToggle(
                                    isOn: $settings.allowsProfanity,
                                    icon: "flame",
                                    activeColor: gradientColors
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
                            )
                        }
                        
                        VStack(spacing: 25) {
                            VStack(spacing: 20) {
                                Text("Speech Settings")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundStyle(gradientColors)
                                
                                CustomAccentPicker(selectedAccent: $settings.speechAccent)
                                
                                CustomSpeedSlider(value: $speechSpeedSliderValue, range: 0.1...1.0, step: 0.1, emoji: ("🐢", "🐇"), onChange: { newValue in
                                    settings.speechSpeed = newValue
                                })
                                
                                CustomSpeedSlider(value: $speechPitchSliderValue, range: 0.5...2.0, step: 0.1, emoji: ("🔽", "🔼"), onChange: { newValue in
                                    settings.speechPitch = newValue
                                })
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 30)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.08), radius: 15, y: 8)
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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
    }
}

#Preview {
    SettingsView(settings: .constant(RoastSettings()))
}
