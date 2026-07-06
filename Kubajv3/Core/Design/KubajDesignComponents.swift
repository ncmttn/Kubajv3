import SwiftUI

struct KubajHeaderActionButton: View {
  let systemImage: String
  var tint: Color = KubajColor.primary
  var isDestructive: Bool = false
  var isEnabled: Bool = true
  let action: () -> Void

  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    Button(action: action) {
      Image(systemName: systemImage)
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(foregroundColor)
        .frame(width: 32, height: 32)
        .background(KubajThemeColors.inputBackground(colorScheme), in: Circle())
    }
    .buttonStyle(.plain)
    .disabled(!isEnabled)
    .opacity(isEnabled ? 1 : 0.45)
  }

  private var foregroundColor: Color {
    guard isEnabled else {
      return KubajThemeColors.textMuted(colorScheme)
    }
    return isDestructive ? Color(red: 0.9, green: 0.25, blue: 0.25) : tint
  }
}

struct KubajHeader: View {
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    HStack {
      HStack(spacing: 12) {
        Image(systemName: "tree.fill")
          .font(.system(size: 18, weight: .bold))
          .foregroundStyle(KubajColor.primary)

        Text(L10n.App.name)
          .font(.system(size: 20, weight: .bold))
          .foregroundStyle(KubajThemeColors.textHeading(colorScheme))
          .tracking(-1)
      }

      Spacer()

      Circle()
        .fill(KubajThemeColors.inputBackground(colorScheme))
        .frame(width: 32, height: 32)
        .overlay {
          Image(systemName: "person.fill")
            .font(.system(size: 14))
            .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
        }
        .overlay {
          Circle()
            .stroke(KubajThemeColors.borderSubtle(colorScheme), lineWidth: 1)
        }
    }
    .padding(.horizontal, KubajMetric.horizontalPadding)
    .padding(.top, 16)
    .padding(.bottom, 17)
    .background(.ultraThinMaterial)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(KubajThemeColors.borderSubtle(colorScheme))
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
  var isFocused: Bool? = nil
  var selectAllOnFocus: Bool = false
  var returnKeyType: UIReturnKeyType = .next
  var onBeginEditing: (() -> Void) = {}
  var onSubmit: (() -> Void) = {}
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(title)
        .font(KubajFont.labelCaps())
        .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
        .textCase(.uppercase)
        .tracking(1)
        .padding(.leading, 8)
        .padding(.bottom, 6)

      HStack(spacing: 0) {
        SelectAllTextField(
          text: $text,
          placeholder: title,
          keyboardType: keyboard,
          returnKeyType: returnKeyType,
          isFocused: isFocused,
          selectAllOnFocus: selectAllOnFocus,
          onReturn: onSubmit,
          onBeginEditing: onBeginEditing
        )
        .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
          onBeginEditing()
        }

        if let trailingActionTitle, let onTrailingAction {
          Button(action: onTrailingAction) {
            Text(trailingActionTitle)
              .font(.system(size: 16, weight: .bold))
              .foregroundStyle(KubajColor.primary)
              .padding(.horizontal, 12)
              .padding(.vertical, 8)
              .background(KubajThemeColors.card(colorScheme), in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusSmall))
              .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 1, y: 1)
          }
          .padding(4)
        }
      }
      .background(KubajThemeColors.inputBackground(colorScheme), in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium))
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

struct KubajOutlineCapsuleButton: View {
  let title: String
  var systemImage: String? = nil
  let action: () -> Void
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    Button(action: action) {
      HStack(spacing: 6) {
        if let systemImage {
          Image(systemName: systemImage)
            .font(.system(size: 14, weight: .semibold))
        }
        Text(title)
          .font(KubajFont.button())
      }
      .foregroundStyle(KubajColor.primary)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 12)
      .background(KubajThemeColors.card(colorScheme), in: Capsule())
      .overlay {
        Capsule()
          .stroke(KubajColor.primary.opacity(0.35), lineWidth: 1)
      }
    }
    .buttonStyle(.plain)
  }
}

struct KubajSettingsLinkRow: View {
  let title: String
  let subtitle: String?
  let systemImage: String
  let iconColor: Color
  let action: () -> Void
  @Environment(\.colorScheme) private var colorScheme

  init(
    title: String,
    subtitle: String? = nil,
    systemImage: String,
    iconColor: Color,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.subtitle = subtitle
    self.systemImage = systemImage
    self.iconColor = iconColor
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        RoundedRectangle(cornerRadius: 10)
          .fill(iconColor.opacity(0.15))
          .frame(width: 40, height: 40)
          .overlay {
            Image(systemName: systemImage)
              .font(.system(size: 16, weight: .semibold))
              .foregroundStyle(iconColor)
          }

        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))
          if let subtitle {
            Text(subtitle)
              .font(.system(size: 13))
              .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
          }
        }

        Spacer()

        Image(systemName: "chevron.right")
          .font(.system(size: 12, weight: .semibold))
          .foregroundStyle(KubajThemeColors.textMuted(colorScheme))
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
    }
    .buttonStyle(.plain)
  }
}

struct KubajStatsCard: View {
  let totalVolume: String
  let logsCount: String
  let averageDiameter: String
  let onReset: () -> Void

  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 4) {
          Text(L10n.Home.totalVolume)
            .font(KubajFont.labelCaps())
            .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
            .tracking(2)
            .textCase(.uppercase)

          HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(totalVolume)
              .font(KubajFont.volumeHero())
              .foregroundStyle(KubajColor.primary)
              .tracking(-0.9)
            Text(L10n.Home.cubicMeterUnit)
              .font(.system(size: 18, weight: .semibold))
              .foregroundStyle(KubajThemeColors.textMuted(colorScheme))
          }
        }

        Spacer()

        Button(action: onReset) {
          Circle()
            .fill(KubajThemeColors.inputBackground(colorScheme))
            .frame(width: 40, height: 40)
            .overlay {
              Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
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
          .fill(KubajThemeColors.borderSubtle(colorScheme))
          .frame(height: 1)
      }
      .padding(.top, 16)
    }
    .padding(KubajMetric.horizontalPadding)
    .background(KubajThemeColors.surface(colorScheme), in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusLarge))
  }

  private func statBlock(title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(title)
        .font(KubajFont.labelCaps())
        .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
        .textCase(.uppercase)
        .tracking(1)
      Text(value)
        .font(KubajFont.statValue())
        .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))
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
              .font(.system(size: 16, weight: .semibold))
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
    .padding(.top, 4)
    .padding(.bottom, 4)
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
  case folders
  case settings

  var id: Self { self }

  var title: String {
    switch self {
    case .home:
      L10n.Tab.home
    case .groups:
      L10n.Tab.groups
    case .folders:
      L10n.Tab.folders
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
    case .folders:
      "folder.fill"
    case .settings:
      "gearshape.fill"
    }
  }
}

struct KubajStatTile: View {
  let title: String
  let value: String
  var valueColor: Color? = nil
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
        .textCase(.uppercase)
        .tracking(0.5)

      Text(value)
        .font(.system(size: 24, weight: .bold))
        .foregroundStyle(valueColor ?? KubajThemeColors.textPrimary(colorScheme))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(KubajThemeColors.card(colorScheme), in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium))
    .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 1, y: 1)
  }
}

struct KubajSectionHeader: View {
  let overline: String?
  let title: String
  let subtitle: String?
  @Environment(\.colorScheme) private var colorScheme

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
          .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
          .textCase(.uppercase)
          .tracking(1.2)
      }

      Text(title)
        .font(.system(size: 30, weight: .heavy))
        .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))
        .tracking(-0.75)

      if let subtitle {
        Text(subtitle)
          .font(.system(size: 16))
          .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
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
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(label)
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
        .padding(.leading, 4)

      TextField(placeholder, text: $text)
        .keyboardType(keyboard)
        .font(.system(size: 16))
        .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(KubajThemeColors.inputBackground(colorScheme), in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium))
    }
  }
}

struct KubajSecondaryButton: View {
  let title: String
  let action: () -> Void
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
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

struct KubajSettingsSectionLabel: View {
  let title: String
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    Text(title)
      .font(.system(size: 12, weight: .semibold))
      .foregroundStyle(KubajThemeColors.textMuted(colorScheme))
      .textCase(.uppercase)
      .tracking(1.2)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 16)
  }
}

struct KubajSettingsToggleRow: View {
  let title: String
  let systemImage: String
  let iconColor: Color
  @Binding var isOn: Bool
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    HStack(spacing: 12) {
      RoundedRectangle(cornerRadius: 10)
        .fill(iconColor.opacity(0.15))
        .frame(width: 40, height: 40)
        .overlay {
          Image(systemName: systemImage)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(iconColor)
        }

      Text(title)
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))

      Spacer()

      Toggle("", isOn: $isOn)
        .labelsHidden()
        .tint(KubajColor.primary)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
  }
}

struct KubajFormulaOptionButton: View {
  let title: String
  let subtitle: String
  let isSelected: Bool
  let action: () -> Void
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Text(title)
          .font(.system(size: 16, weight: .bold))
        Text(subtitle)
          .font(.system(size: 12, weight: .medium))
          .multilineTextAlignment(.center)
      }
      .foregroundStyle(isSelected ? Color.white : KubajThemeColors.textPrimary(colorScheme))
      .frame(maxWidth: .infinity)
      .padding(.vertical, 12)
      .background {
        RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium)
          .fill(
            isSelected
              ? AnyShapeStyle(LinearGradient(
                  colors: [KubajColor.primary, KubajColor.primaryEnd],
                  startPoint: .leading,
                  endPoint: .trailing
                ))
              : AnyShapeStyle(KubajThemeColors.card(colorScheme))
          )
      }
      .overlay {
        RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium)
          .stroke(isSelected ? Color.clear : KubajThemeColors.borderSubtle(colorScheme), lineWidth: 1)
      }
      .shadow(color: isSelected ? KubajColor.primary.opacity(0.2) : .clear, radius: 8, y: 4)
    }
    .buttonStyle(.plain)
  }
}
