//
//  SwipeBackModifier.swift
//  BurnBook
//
//  Created by Ayush Kumar Singh on 5/31/25.
//
import SwiftUI

/// Adds a custom “swipe from the very left edge” gesture that triggers `dismiss()`.
struct SwipeBackModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    
    // How many points the user must drag rightwards before we dismiss.
    private let activationDistance: CGFloat = 100
    
    func body(content: Content) -> some View {
        content
            
            .simultaneousGesture(
                DragGesture()
                    .onEnded { value in
                        
                        if value.startLocation.x < 30,
                           value.translation.width  > activationDistance,
                           abs(value.translation.height) < 50 {
                            dismiss()
                        }
                    }
            )
    }
}

extension View {
    /// Call `.enableEdgeSwipeBack()` on any screen where you hide the default back button
    /// but still want the interactive swipe-to-go-back behaviour.
    func enableEdgeSwipeBack() -> some View {
        modifier(SwipeBackModifier())
    }
}
