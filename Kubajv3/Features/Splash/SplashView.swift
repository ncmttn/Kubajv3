import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 12

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [KubajColor.primary, KubajColor.primaryEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 320, height: 320)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 128, height: 128)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 104, height: 104)
                        .shadow(color: .black.opacity(0.18), radius: 18, y: 8)

                    Image(systemName: "tree.fill")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [KubajColor.primary, KubajColor.primaryEnd],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: 8) {
                    Text(L10n.App.name)
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundStyle(.white)
                        .tracking(-1)

                    Text(L10n.Splash.tagline)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
                .opacity(textOpacity)
                .offset(y: textOffset)
            }
            .padding(.horizontal, 32)
        }
        .onAppear(perform: animate)
    }

    private func animate() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            logoScale = 1
            logoOpacity = 1
        }
        withAnimation(.easeOut(duration: 1.1)) {
            ringScale = 1.15
            ringOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.35)) {
            textOpacity = 1
            textOffset = 0
        }
    }
}

#Preview {
    SplashView()
}
