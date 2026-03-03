import SwiftUI

struct ItemTrayView: View {
    @EnvironmentObject var store: AppStore

    @State private var showAddItem = false
    @State private var itemToEdit: PocketItem? = nil

    var body: some View {
        HStack(spacing: 12) {

            // ── Standalone + button ───────────────────────────────────────
            Button {
                showAddItem = true
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.6),
                                            Color.white.opacity(0.1),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            // ── Liquid glass item tray with edge fade clipping ────────────
            GeometryReader { geo in
                let capsuleHeight = geo.size.height
                let cornerRadius = capsuleHeight / 2  // true capsule radius

                ZStack {
                    // The glass background
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            // Top highlight
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.25),
                                            Color.white.opacity(0.0),
                                        ],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                        }
                        .overlay {
                            // Glass border
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.55),
                                            Color.white.opacity(0.10),
                                            Color.white.opacity(0.30),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                        .shadow(color: .black.opacity(0.20), radius: 16, y: 6)
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

                    // Scroll content clipped + faded at curved edges
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(store.trayItems) { item in
                                TrayItemView(item: item)
                                    .onTapGesture { itemToEdit = item }
                                    .contextMenu {
                                        Button {
                                            itemToEdit = item
                                        } label: {
                                            Label(
                                                "Edit Item",
                                                systemImage: "pencil"
                                            )
                                        }
                                        Button(role: .destructive) {
                                            store.deleteTrayItem(id: item.id)
                                        } label: {
                                            Label(
                                                "Delete Item",
                                                systemImage: "trash"
                                            )
                                        }
                                    }
                            }
                        }
                        // Inner padding matches the capsule curve so items
                        // start/end flush with where the curve straightens out
                        .padding(.horizontal, cornerRadius * 0.75)
                        .padding(.vertical, 10)
                    }
                    // Clip strictly to capsule shape so nothing bleeds outside
                    .clipShape(Capsule())
                    // Fade mask — items dissolve exactly at the curved edges
                    .mask {
                        HStack(spacing: 0) {
                            // Left fade — matches capsule curve width
                            LinearGradient(
                                colors: [.clear, .black],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: cornerRadius)

                            // Fully opaque middle
                            Rectangle()
                                .fill(Color.black)

                            // Right fade — mirrors left
                            LinearGradient(
                                colors: [.black, .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: cornerRadius)
                        }
                    }
                }
            }
            .frame(height: 56)
        }
        .sheet(isPresented: $showAddItem) {
            AddEditItemView { newItem in store.addTrayItem(newItem) }
        }
        .sheet(item: $itemToEdit) { item in
            AddEditItemView(existingItem: item) { updated in
                store.updateTrayItem(updated)
            } onDelete: {
                store.deleteTrayItem(id: item.id)
            }
        }
    }
}

// MARK: - TrayItemView

struct TrayItemView: View {
    let item: PocketItem
    @State private var isDragging = false

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(
                                            isDragging ? 0.4 : 0.22
                                        ),
                                        Color.white.opacity(0.0),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.1),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: .black.opacity(isDragging ? 0.22 : 0.10),
                        radius: isDragging ? 10 : 5,
                        y: isDragging ? 6 : 3
                    )

                Image(systemName: item.sfSymbol)
                    .font(.system(size: 25))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
            }
            .scaleEffect(isDragging ? 1.15 : 1.0)
            .animation(
                .spring(response: 0.25, dampingFraction: 0.7),
                value: isDragging
            )

        }
        .draggable(item.id.uuidString) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                Color.white.opacity(0.5),
                                lineWidth: 1
                            )
                    )
                Image(systemName: item.sfSymbol)
                    .font(.system(size: 26))
                    .foregroundStyle(.white)
            }
            .shadow(color: .black.opacity(0.3), radius: 16, y: 8)
            .onAppear { isDragging = true }
            .onDisappear { isDragging = false }
        }
    }
}
