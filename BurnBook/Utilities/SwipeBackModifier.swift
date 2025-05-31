import SwiftUI

/// Adds a custom “swipe from the very left edge” gesture that triggers `dismiss()`.
struct SwipeBackModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    
    // How many points the user must drag rightwards before we dismiss.
    private let activationDistance: CGFloat = 100
    
    func body(content: Content) -> some View {
        content
            // Use simultaneousGesture so both our drag and the scroll view's drag
            // can be recognised. We still check that the drag starts on the very
            // left edge and is mostly horizontal before calling `dismiss()`.
            .simultaneousGesture(
                DragGesture()
                    .onEnded { value in
                        // ❶ start near the left screen edge ❷ mostly horizontal ❸ dragged far enough
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
