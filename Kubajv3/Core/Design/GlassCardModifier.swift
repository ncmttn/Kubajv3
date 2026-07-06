import SwiftUI

struct GlassCardModifier: ViewModifier {
    var material: Material = .ultraThinMaterial
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .background(material, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            }
    }
}

extension View {
    func glassCard(material: Material = .ultraThinMaterial, cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCardModifier(material: material, cornerRadius: cornerRadius))
    }
}
