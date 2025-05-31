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
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("😊")
                    .font(.title2)
                    .opacity(value == 0 ? 1.0 : 0.5)
                Spacer()
                Text("😈")
                    .font(.title2)
                    .opacity(value == 1 ? 1.0 : 0.5)
                Spacer()
                Text("💀")
                    .font(.title2)
                    .opacity(value == 2 ? 1.0 : 0.5)
            }
            
            ZStack {
                // Track
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                // Active track
                HStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(colors: [.orange, .red],
                                         startPoint: .leading,
                                         endPoint: .trailing)
                        )
                        .frame(width: CGFloat(value / 2.0) * 260, height: 8)
                    Spacer()
                }
                
                // Slider handle
                HStack {
                    Spacer()
                        .frame(width: CGFloat(value / 2.0) * 260)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
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
                    
                    Spacer()
                }
            }
           
            .frame(width: 260)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let percent = min(max(0, gesture.location.x / 260), 1)
                        let newValue = round(percent * 2)
                        if newValue != value {
                            value = newValue
                            onChange(newValue)
                        }
                    }
            )
            .onTapGesture { gesture in
                let percent = min(max(0, gesture.x / 260), 1)
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

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var settings: RoastSettings
    @State private var intensitySliderValue: Double
    
    init(settings: Binding<RoastSettings>) {
        self._settings = settings
        self._intensitySliderValue = State(initialValue: settings.wrappedValue.intensity.sliderValue)
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
                                    }
                                    Text("Include political burns")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
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
                                    }
                                    Text("Allow spicy language")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                CustomToggle(
                                    isOn: $settings.allowsProfanity,
                                    icon: "flame",
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
                        }
                    }
                    .padding(.horizontal, 30)
                }
                
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Text("🔥")
                            .font(.title2)
                        Text("Let's Roast!")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(gradientColors)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    SettingsView(settings: .constant(RoastSettings()))
}
