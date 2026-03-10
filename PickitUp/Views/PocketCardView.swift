import SwiftUI

struct PocketCardView: View {
    @EnvironmentObject var store: AppStore
    var pocket: Pocket
    var onEdit: () -> Void

    private var isReady: Bool {
        !pocket.items.isEmpty
    }

    private var statusTitle: String {
        isReady ? "Ready" : "Needs Items"
    }

    private var statusIcon: String {
        isReady ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Top row
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(UITheme.surface.opacity(0.82))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    UITheme.primary.opacity(0.12),
                                    lineWidth: 1.2
                                )
                        )

                    Image(systemName: pocket.sfSymbol)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(UITheme.primary)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center, spacing: 8) {
                        Text(pocket.name)
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(UITheme.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Spacer(minLength: 8)

                        statusBadge
                    }

                    Text("\(pocket.daysSummary) • \(pocket.reminderTimeString)")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(UITheme.primary.opacity(0.68))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(itemSummaryText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(UITheme.primary.opacity(0.56))
                }
            }
            .padding(.bottom, 14)

            pocketDivider
                .padding(.bottom, 14)

            // MARK: Items area
            if pocket.items.isEmpty {
                emptyState
            } else {
                itemRow(pocket.items)
            }

            // MARK: Bottom actions
            HStack(spacing: 10) {
                Button(action: onEdit) {
                    Label("Edit Pocket", systemImage: "pencil")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(UITheme.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(UITheme.buttonSecondaryBackground, in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityHint("Opens this pocket for editing")

                Spacer()

                if isReady {
                    Label("Packed", systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(UITheme.success)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(UITheme.surface.opacity(0.46), in: Capsule())
                        .accessibilityLabel("Pocket status packed")
                }
            }
            .padding(.top, 16)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            UITheme.surface.opacity(0.24),
                            UITheme.surface.opacity(0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(
                            UITheme.primary.opacity(0.38),
                            style: StrokeStyle(lineWidth: 1.5, dash: [8, 5])
                        )
                )
                .overlay(alignment: .bottom) {
                    stitchLine
                        .padding(.horizontal, 18)
                        .padding(.bottom, 12)
                }
                .shadow(color: .black.opacity(0.08), radius: 6, y: 4)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilitySummary)
    }

    // MARK: Subviews

    private var statusBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: statusIcon)
                .font(.caption.weight(.bold))
                .accessibilityHidden(true)

            Text(statusTitle)
                .font(.caption2)
                .fontWeight(.bold)
        }
        .foregroundStyle(statusColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(UITheme.surface.opacity(0.52), in: Capsule())
    }

    private var statusColor: Color {
        isReady ? UITheme.success : UITheme.warning
    }

    private var pocketDivider: some View {
        Rectangle()
            .fill(Color(red: 0.82, green: 0.70, blue: 0.45).opacity(0.72))
            .frame(height: 1.4)
            .overlay(
                Rectangle()
                    .fill(UITheme.surface.opacity(0.22))
                    .frame(height: 0.6)
                    .offset(y: -1),
                alignment: .top
            )
    }

    private var stitchLine: some View {
        HStack(spacing: 6) {
            ForEach(0..<26, id: \.self) { _ in
                Capsule()
                    .fill(Color(red: 0.84, green: 0.72, blue: 0.46).opacity(0.72))
                    .frame(width: 7, height: 2)
            }
        }
        .accessibilityHidden(true)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(UITheme.surface.opacity(0.34))
                    .frame(width: 60, height: 60)

                Image(systemName: "shippingbox")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(UITheme.primary.opacity(0.56))
            }
            .accessibilityHidden(true)

            Text("This pocket is still empty")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(UITheme.primary.opacity(0.74))

            Text("Add your essentials so this pocket is ready before you leave.")
                .font(.caption)
                .foregroundStyle(UITheme.primary.opacity(0.54))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private func itemRow(_ items: [PocketItem]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(items) { item in
                    ItemChip(item: item)
                        .contextMenu {
                            Button(role: .destructive) {
                                store.removeItemFromPocket(itemId: item.id, pocketId: pocket.id)
                            } label: {
                                Label("Remove from pocket", systemImage: "minus.circle")
                            }
                        }
                        .accessibilityHint("Shows item \(item.name)")
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var itemSummaryText: String {
        let count = pocket.items.count
        if count == 0 { return "No items inside yet" }
        if count == 1 { return "1 item inside" }
        return "\(count) items inside"
    }

    private var accessibilitySummary: String {
        "\(pocket.name). \(pocket.daysSummary), \(pocket.reminderTimeString). \(itemSummaryText). Status: \(statusTitle)."
    }
}

// MARK: - ItemChip

struct ItemChip: View {
    let item: PocketItem

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(UITheme.surface.opacity(0.84))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                UITheme.primary.opacity(0.15),
                                lineWidth: 1.3
                            )
                    )
                    .shadow(color: .black.opacity(0.07), radius: 4, y: 2)

                Image(systemName: item.sfSymbol)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(UITheme.primary)
            }

            Text(item.name)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(UITheme.primary.opacity(0.74))
                .lineLimit(1)
                .frame(width: 62)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.name)
    }
}
