import SwiftUI

struct KubajHeader: View {
  var body: some View {
    HStack {
      HStack(spacing: 12) {
        Image(systemName: "tree.fill")
          .font(.system(size: 18, weight: .bold))
          .foregroundStyle(KubajColor.primary)

        Text(L10n.App.name)
          .font(.system(size: 20, weight: .bold))
          .foregroundStyle(KubajColor.textHeading)
          .tracking(-1)
      }

      Spacer()

      Circle()
        .fill(KubajColor.inputBackground)
        .frame(width: 32, height: 32)
        .overlay {
          Image(systemName: "person.fill")
            .font(.system(size: 14))
            .foregroundStyle(KubajColor.textSecondary)
        }
        .overlay {
          Circle()
            .stroke(KubajColor.borderSubtle, lineWidth: 1)
        }
    }
    .padding(.horizontal, KubajMetric.horizontalPadding)
    .padding(.top, 16)
    .padding(.bottom, 17)
    .background(.ultraThinMaterial)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(KubajColor.borderSubtle)
        .frame(height: 1)
    }
  }
}

struct KubajInputField: View {
  let title: String
  @Binding var text: String
  var keyboard: UIKeyboardType = .decimalPad
  var trailingActionTitle: String?
  var onTrailingAction: (() -> Void)?

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(title)
        .font(KubajFont.labelCaps())
        .foregroundStyle(KubajColor.textSecondary)
        .textCase(.uppercase)
        .tracking(1)
        .padding(.leading, 8)
        .padding(.bottom, 6)

      HStack(spacing: 0) {
        TextField(title, text: $text)
          .keyboardType(keyboard)
          .font(KubajFont.inputValue())
          .foregroundStyle(KubajColor.textPrimary)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity, alignment: .leading)

        if let trailingActionTitle, let onTrailingAction {
          Button(action: onTrailingAction) {
            Text(trailingActionTitle)
              .font(.system(size: 16, weight: .bold))
              .foregroundStyle(KubajColor.primary)
              .padding(.horizontal, 12)
              .padding(.vertical, 8)
              .background(Color.white, in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusSmall))
              .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
          }
          .padding(4)
        }
      }
      .background(KubajColor.inputBackground, in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium))
    }
  }
}

struct KubajPrimaryButton: View {
  let title: String
  var isEnabled: Bool = true
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(KubajFont.button())
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
          LinearGradient(
            colors: isEnabled ? [KubajColor.primary, KubajColor.primaryEnd] : [KubajColor.textMuted, KubajColor.textMuted],
            startPoint: .leading,
            endPoint: .trailing
          ),
          in: Capsule()
        )
        .shadow(color: KubajColor.primary.opacity(isEnabled ? 0.2 : 0), radius: 8, y: 4)
    }
    .disabled(!isEnabled)
  }
}

struct KubajStatsCard: View {
  let totalVolume: String
  let logsCount: String
  let averageDiameter: String
  let onReset: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 4) {
          Text(L10n.Home.totalVolume)
            .font(KubajFont.labelCaps())
            .foregroundStyle(KubajColor.textSecondary)
            .tracking(2)
            .textCase(.uppercase)

          HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(totalVolume)
              .font(KubajFont.volumeHero())
              .foregroundStyle(KubajColor.primary)
              .tracking(-0.9)
            Text(L10n.Home.cubicMeterUnit)
              .font(.system(size: 18, weight: .semibold))
              .foregroundStyle(KubajColor.textMuted)
          }
        }

        Spacer()

        Button(action: onReset) {
          Circle()
            .fill(KubajColor.inputBackground)
            .frame(width: 40, height: 40)
            .overlay {
              Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(KubajColor.textSecondary)
            }
        }
      }

      HStack(spacing: 32) {
        statBlock(title: L10n.Home.logsCount, value: logsCount)
        statBlock(title: L10n.Home.avgDiameter, value: averageDiameter)
      }
      .padding(.top, 1)
      .overlay(alignment: .top) {
        Rectangle()
          .fill(KubajColor.borderSubtle)
          .frame(height: 1)
      }
      .padding(.top, 16)
    }
    .padding(KubajMetric.horizontalPadding)
    .background(KubajColor.surface, in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusLarge))
  }

  private func statBlock(title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(title)
        .font(KubajFont.labelCaps())
        .foregroundStyle(KubajColor.textSecondary)
        .textCase(.uppercase)
        .tracking(1)
      Text(value)
        .font(KubajFont.statValue())
        .foregroundStyle(KubajColor.textPrimary)
    }
  }
}

struct KubajTabBar: View {
  @Binding var selection: AppTab

  var body: some View {
    HStack(spacing: 0) {
      ForEach(AppTab.allCases) { tab in
        Button {
          selection = tab
          HapticFeedback.light()
        } label: {
          VStack(spacing: 4) {
            Image(systemName: tab.iconName)
              .font(.system(size: tab == .hollow ? 20 : 16, weight: .semibold))
            Text(tab.title)
              .font(KubajFont.tabLabel())
              .textCase(.uppercase)
              .tracking(0.275)
          }
          .foregroundStyle(selection == tab ? KubajColor.tabActive : KubajColor.tabInactive)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.horizontal, 20)
    .padding(.top, 8)
    .padding(.bottom, 20)
    .background(.ultraThinMaterial)
    .overlay(alignment: .top) {
      Rectangle()
        .fill(Color.white.opacity(0.2))
        .frame(height: 1)
    }
    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    .shadow(color: .black.opacity(0.04), radius: 12, y: -4)
  }
}

enum AppTab: CaseIterable, Identifiable {
  case home
  case groups
  case hollow
  case settings

  var id: Self { self }

  var title: String {
    switch self {
    case .home:
      L10n.Tab.home
    case .groups:
      L10n.Tab.groups
    case .hollow:
      L10n.Tab.hollow
    case .settings:
      L10n.Tab.settings
    }
  }

  var iconName: String {
    switch self {
    case .home:
      "house.fill"
    case .groups:
      "square.stack.3d.up.fill"
    case .hollow:
      "circle.dotted"
    case .settings:
      "gearshape.fill"
    }
  }
}

struct KubajStatTile: View {
  let title: String
  let value: String
  var valueColor: Color = KubajColor.textPrimary

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(KubajColor.textSecondary)
        .textCase(.uppercase)
        .tracking(0.5)

      Text(value)
        .font(.system(size: 24, weight: .bold))
        .foregroundStyle(valueColor)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(Color.white, in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium))
    .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
  }
}

struct KubajSectionHeader: View {
  let overline: String?
  let title: String
  let subtitle: String?

  init(overline: String? = nil, title: String, subtitle: String? = nil) {
    self.overline = overline
    self.title = title
    self.subtitle = subtitle
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if let overline {
        Text(overline)
          .font(.system(size: 12, weight: .regular))
          .foregroundStyle(KubajColor.textSecondary)
          .textCase(.uppercase)
          .tracking(1.2)
      }

      Text(title)
        .font(.system(size: 30, weight: .heavy))
        .foregroundStyle(KubajColor.textPrimary)
        .tracking(-0.75)

      if let subtitle {
        Text(subtitle)
          .font(.system(size: 16))
          .foregroundStyle(KubajColor.textSecondary)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct KubajFormField: View {
  let label: String
  let placeholder: String
  @Binding var text: String
  var keyboard: UIKeyboardType = .default

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(label)
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(KubajColor.textSecondary)
        .padding(.leading, 4)

      TextField(placeholder, text: $text)
        .keyboardType(keyboard)
        .font(.system(size: 16))
        .foregroundStyle(KubajColor.textPrimary)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(KubajColor.inputBackground, in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium))
    }
  }
}

struct KubajSecondaryButton: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(KubajColor.textSecondary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium))
    }
  }
}

struct KubajRectPrimaryButton: View {
  let title: String
  var systemImage: String? = nil
  var isEnabled: Bool = true
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 8) {
        if let systemImage {
          Image(systemName: systemImage)
            .font(.system(size: 16, weight: .bold))
        }
        Text(title)
          .font(.system(size: 16, weight: .bold))
      }
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(
        LinearGradient(
          colors: isEnabled ? [KubajColor.primary, KubajColor.primaryEnd] : [KubajColor.textMuted, KubajColor.textMuted],
          startPoint: .leading,
          endPoint: .trailing
        ),
        in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium)
      )
      .shadow(color: KubajColor.primary.opacity(isEnabled ? 0.15 : 0), radius: 8, y: 4)
    }
    .disabled(!isEnabled)
  }
}

struct KubajSettingsCard<Content: View>: View {
  let title: String
  @ViewBuilder var content: Content

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(title)
        .font(.system(size: 14, weight: .bold))
        .foregroundStyle(KubajColor.textSecondary)
        .textCase(.uppercase)
        .tracking(1)

      content
    }
    .padding(KubajMetric.horizontalPadding)
    .background(KubajColor.surface, in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusLarge))
  }
}

