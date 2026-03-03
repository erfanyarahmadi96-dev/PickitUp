import SwiftUI
import MapKit

struct PocketCardView: View {
    @EnvironmentObject var store: AppStore
    var pocket: Pocket
    var onEdit: () -> Void

    @State private var isTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ───────────────────────────────────────────────────
            HStack(spacing: 10) {
                Image(systemName: pocket.sfSymbol)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red:0.12,green:0.12,blue:0.18))

                Text(pocket.name)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(red:0.12,green:0.12,blue:0.18))

                Spacer()

                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(red:0.12,green:0.12,blue:0.18))
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 4)

            // Reminder subtitle
            Text("Reminder: \(pocket.daysSummary) \(pocket.reminderTimeString)")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color(red:0.12,green:0.12,blue:0.18).opacity(0.6))
                .padding(.bottom, 14)

            // ── Location mini-map ────────────────────────────────────────
            MapPreview(coordinate: pocket.location.coordinate, name: pocket.location.name)
                .frame(height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(alignment: .bottomLeading) {
                    Label(pocket.location.name, systemImage: "mappin.fill")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(6)
                }
                .padding(.bottom, 14)

            // ── Open items ───────────────────────────────────────────────
            if pocket.items.isEmpty && !isTargeted {
                Text("Drag items here from the tray below")
                    .font(.caption)
                    .foregroundStyle(Color(red:0.12,green:0.12,blue:0.18).opacity(0.35))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                // Open section (all items for now — you can split open/close in model later)
                let openItems = pocket.items

                if !openItems.isEmpty {
                    itemRow(openItems)
                }

                // Drop indicator
                if isTargeted {
                    HStack {
                        Spacer()
                        Label("Drop here", systemImage: "arrow.down.circle.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(red:0.12,green:0.12,blue:0.18).opacity(0.5))
                        Spacer()
                    }
                    .padding(.top, openItems.isEmpty ? 0 : 10)
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(isTargeted ? 0.30 : 0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(
                            Color(red:0.12,green:0.12,blue:0.18).opacity(isTargeted ? 0.8 : 0.55),
                            style: StrokeStyle(lineWidth: 2, dash: [8, 5])
                        )
                )
        }
        .scaleEffect(isTargeted ? 1.015 : 1.0)
        .animation(.spring(response: 0.3), value: isTargeted)
        .dropDestination(for: String.self) { droppedIds, _ in
            guard let idString = droppedIds.first,
                  let itemId = UUID(uuidString: idString),
                  let item = store.trayItems.first(where: { $0.id == itemId })
            else { return false }
            store.addItemToPocket(item: item, pocketId: pocket.id)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return true
        } isTargeted: { targeted in
            isTargeted = targeted
        }
    }

    // MARK: - Item row

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
                }
            }
        }
    }
}

// MARK: - ItemChip

struct ItemChip: View {
    let item: PocketItem

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.75))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle()
                            .strokeBorder(Color(red:0.12,green:0.12,blue:0.18).opacity(0.18), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                Image(systemName: item.sfSymbol)
                    .font(.system(size: 22))
                    .foregroundStyle(Color(red:0.12,green:0.12,blue:0.18))
            }
            Text(item.name)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color(red:0.12,green:0.12,blue:0.18).opacity(0.7))
                .lineLimit(1)
                .frame(width: 52)
        }
    }
}
