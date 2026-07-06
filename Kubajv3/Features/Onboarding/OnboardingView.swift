import SwiftUI

struct OnboardingView: View {
    @Environment(AppPreferences.self) private var preferences
    @State private var currentStep = 0

    private let stepCount = 3

    var body: some View {
        ZStack {
            KubajColor.background
                .ignoresSafeArea()

            Circle()
                .fill(KubajColor.primary.opacity(0.05))
                .frame(width: 256, height: 256)
                .blur(radius: 50)
                .offset(x: -96, y: 300)

            Circle()
                .fill(KubajColor.primary.opacity(0.05))
                .frame(width: 320, height: 320)
                .blur(radius: 50)
                .offset(x: 120, y: -200)

            VStack(spacing: 0) {
                Spacer(minLength: 48)

                illustrationCard
                    .padding(.horizontal, 32)

                textContent
                    .padding(.horizontal, 32)
                    .padding(.top, 48)

                Spacer()

                pagination
                    .padding(.bottom, 40)

                VStack(spacing: 16) {
                    KubajRectPrimaryButton(
                        title: currentStep == stepCount - 1 ? L10n.Onboarding.getStarted : L10n.Onboarding.nextStep,
                        systemImage: "arrow.right"
                    ) {
                        advance()
                    }

                    if currentStep < stepCount - 1 {
                        KubajSecondaryButton(title: L10n.Onboarding.skipIntro) {
                            completeOnboarding()
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }

    private var illustrationCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 40)
                .fill(KubajColor.surface)
                .aspectRatio(4 / 5, contentMode: .fit)
                .overlay {
                    Image(systemName: stepIcon)
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(KubajColor.primary.opacity(0.35))
                }
                .shadow(color: KubajColor.textPrimary.opacity(0.05), radius: 25, y: 12)

            HStack(spacing: 8) {
                Image(systemName: "tree.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                Text(L10n.App.name.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(1.2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(24)
        }
    }

    private var stepIcon: String {
        switch currentStep {
        case 0:
            "ruler"
        case 1:
            "square.stack.3d.up.fill"
        default:
            "doc.richtext"
        }
    }

    private var textContent: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                Text(stepTitleLine1)
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundStyle(KubajColor.textPrimary)
                    .tracking(-2.2)
                Text(stepTitleLine2)
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundStyle(KubajColor.primary)
                    .tracking(-2.2)
            }
            .multilineTextAlignment(.center)

            Text(stepSubtitle)
                .font(.system(size: 18))
                .foregroundStyle(KubajColor.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var stepTitleLine1: String {
        switch currentStep {
        case 0:
            L10n.Onboarding.step1TitleLine1
        case 1:
            L10n.Onboarding.step2TitleLine1
        default:
            L10n.Onboarding.step3TitleLine1
        }
    }

    private var stepTitleLine2: String {
        switch currentStep {
        case 0:
            L10n.Onboarding.step1TitleLine2
        case 1:
            L10n.Onboarding.step2TitleLine2
        default:
            L10n.Onboarding.step3TitleLine2
        }
    }

    private var stepSubtitle: String {
        switch currentStep {
        case 0:
            L10n.Onboarding.step1Subtitle
        case 1:
            L10n.Onboarding.step2Subtitle
        default:
            L10n.Onboarding.step3Subtitle
        }
    }

    private var pagination: some View {
        HStack(spacing: 8) {
            ForEach(0..<stepCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? KubajColor.primary : KubajColor.inputBackground)
                    .frame(width: index == currentStep ? 32 : 6, height: 6)
                    .shadow(color: index == currentStep ? KubajColor.primary.opacity(0.3) : .clear, radius: 6)
            }
        }
    }

    private func advance() {
        HapticFeedback.light()
        if currentStep < stepCount - 1 {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentStep += 1
            }
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        HapticFeedback.medium()
        preferences.hasCompletedOnboarding = true
    }
}

#Preview {
    OnboardingView()
        .environment(AppPreferences.shared)
}
