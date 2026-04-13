import SwiftUI

enum PaywallContext: Equatable {
    case firstFast
    case lockedPreset(FastPreset)
    case history
    case settings

    var badge: String {
        switch self {
        case .firstFast:
            return "Before your first fast"
        case .lockedPreset:
            return "Preset locked"
        case .history:
            return "History locked"
        case .settings:
            return "Full unlock"
        }
    }

    var title: String {
        switch self {
        case .firstFast:
            return "Unlock before you start"
        case .lockedPreset(let preset):
            return "Unlock \(preset.displayName)"
        case .history:
            return "Unlock your fasting history"
        case .settings:
            return "Upgrade once, keep it forever"
        }
    }

    var message: String {
        switch self {
        case .firstFast:
            return "Start with every preset available, save history from day one, and keep notifications and widgets ready as you build the habit."
        case .lockedPreset(let preset):
            return "\(preset.displayName) is part of the full unlock, along with all other presets, history, streaks, and the home screen widget."
        case .history:
            return "See completed fasts, streaks, and average duration once you unlock the full app."
        case .settings:
            return "One purchase unlocks every preset, full history, the widget, and completion notifications on this Apple ID."
        }
    }
}

struct MonetizationCard<Content: View>: View {
    let accent: Color
    let content: Content

    init(accent: Color = .accentColor, @ViewBuilder content: () -> Content) {
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray.opacity(0.08))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(accent.opacity(0.14), lineWidth: 1)
        }
    }
}

struct ContextPromptCard: View {
    let context: PaywallContext
    var actionTitle: String = "See Full Unlock"
    let action: () -> Void

    var body: some View {
        MonetizationCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(context.badge.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(context.title)
                    .font(.title3.weight(.semibold))

                Text(context.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button(action: action) {
                HStack {
                    Text(actionTitle)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}

struct PurchaseStatusCard: View {
    let isUnlocked: Bool
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        MonetizationCard(accent: isUnlocked ? .green : .accentColor) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: isUnlocked ? "checkmark.seal.fill" : "lock.circle.fill")
                    .font(.title2)
                    .foregroundStyle(isUnlocked ? .green : .accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(isUnlocked ? "Lifetime unlock active" : "Free access")
                        .font(.headline)

                    Text(isUnlocked
                         ? "All presets, history, streaks, widget support, and notifications are available."
                         : "The free tier includes the 16:8 preset. Unlock once for the full app.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }

            Button(action: action) {
                Text(actionTitle)
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(isUnlocked ? Color.green.opacity(0.12) : Color.accentColor)
                    .foregroundStyle(isUnlocked ? .green : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}

struct PurchaseFeatureList: View {
    let items: [(icon: String, title: String, detail: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: item.icon)
                        .font(.headline)
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 24, alignment: .center)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))
                        Text(item.detail)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct PaywallView: View {
    @EnvironmentObject var purchaseService: PurchaseService
    @Environment(\.dismiss) private var dismiss
    let context: PaywallContext

    init(context: PaywallContext = .settings) {
        self.context = context
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Image(systemName: "timer.circle.fill")
                            .font(.system(size: 62))
                            .foregroundStyle(Color.accentColor)

                        Text(context.badge.uppercased())
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Text("Unlock the full app")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)

                        Text(context.message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                    }

                    MonetizationCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Lifetime unlock")
                                .font(.headline)

                            if let product = purchaseService.product {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(product.displayPrice)
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                    Text("one-time")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                Text(AppConfig.unlockPrice)
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                            }

                            Text("No recurring billing. Restore anytime on devices using the same Apple ID.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    MonetizationCard {
                        Text("Included")
                            .font(.headline)

                        PurchaseFeatureList(items: [
                            ("square.grid.2x2", "All presets", "Unlock 18:6, OMAD, and every future fasting schedule."),
                            ("chart.line.text.clipboard", "History and streaks", "Review completed fasts, averages, and consistency over time."),
                            ("apps.iphone", "Home screen widget", "Keep your current fast visible without opening the app."),
                            ("bell.badge", "Completion notifications", "Get alerted when your fast reaches its target.")
                        ])
                    }

                    if let product = purchaseService.product {
                        VStack(spacing: 12) {
                            Button {
                                Task {
                                    let success = try? await purchaseService.purchase()
                                    if success == true {
                                        dismiss()
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("Unlock for \(product.displayPrice)")
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                }
                                .font(.headline)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 16)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .disabled(purchaseService.isLoading)

                            Button("Restore Purchases") {
                                Task {
                                    await purchaseService.restorePurchases()
                                    if purchaseService.isUnlocked {
                                        dismiss()
                                    }
                                }
                            }
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                        }
                    } else if purchaseService.isLoading {
                        ProgressView("Loading purchase options…")
                    } else {
                        MonetizationCard {
                            Text("Unable to load purchase details.")
                                .font(.subheadline.weight(.semibold))
                            Text("Check your connection and try again from Settings.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    VStack(spacing: 10) {
                        Link("Privacy Policy", destination: AppConfig.privacyPolicyURL)
                        Link("Terms of Service", destination: AppConfig.termsOfServiceURL)
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Dismiss") { dismiss() }
                }
            }
        }
    }
}
