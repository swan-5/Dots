import SwiftUI

/// Persistent floating `+` action. Pinned to the bottom-trailing safe area so it never
/// fights the tab bar or obstructs scroll content.
struct FloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(DotsColor.periwinkle, in: Circle())
                .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
        }
        .accessibilityLabel("새 경험 기록")
        .padding(.trailing, DotsSpacing.md)
        .padding(.bottom, DotsSpacing.md)
    }
}

struct FloatingAddButtonOverlay: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottomTrailing) {
            FloatingAddButton(action: action)
        }
    }
}

extension View {
    func floatingAddButton(action: @escaping () -> Void) -> some View {
        modifier(FloatingAddButtonOverlay(action: action))
    }
}
