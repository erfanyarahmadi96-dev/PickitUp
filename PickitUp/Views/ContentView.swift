import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()

    @State private var quickAlertEnabled = true
    @State private var showAddPocket = false
    @State private var pocketToEdit: Pocket? = nil

    var body: some View {
        ZStack(alignment: .bottom) {

            VStack(spacing: 0) {

                // ── WAISTBAND (light header area) ──────────────────────────
                ZStack(alignment: .bottom) {
                    // Light background — the "waistband" fabric
                    Color(red: 0.95, green: 0.95, blue: 0.96)
                        .ignoresSafeArea(edges: .top)

                    VStack(spacing: 0) {
                        // Title row
                        // Title row
                        HStack(alignment: .center, spacing: 10) {
                            Text("Pockets")
                                .font(
                                    .system(
                                        size: 36,
                                        weight: .bold,
                                        design: .default
                                    )
                                )
                                .foregroundStyle(
                                    Color(red: 0.12, green: 0.12, blue: 0.18)
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)

                            Spacer()

                            // Quick alert toggle — all on one line
                            HStack(spacing: 6) {
                                Text("Quick Alert")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(
                                        Color(
                                            red: 0.12,
                                            green: 0.12,
                                            blue: 0.18
                                        )
                                    )
                                    .lineLimit(1)
                                    .fixedSize()
                                Toggle("", isOn: $quickAlertEnabled)
                                    .labelsHidden()
                                    .tint(.green)
                                    .scaleEffect(0.9)
                                    .fixedSize()
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(
                                Color.white.opacity(0.85),
                                in: Capsule()
                            )
                            .shadow(
                                color: .black.opacity(0.07),
                                radius: 6,
                                y: 2
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 14)  // ── BELT ──────────────────────────────────────────
                        Belt()
                    }
                }
                .fixedSize(horizontal: false, vertical: true)

                // ── DENIM BODY ────────────────────────────────────────────
                ZStack(alignment: .bottom) {
                    // Denim texture background
                    DenimBackground()
                        .ignoresSafeArea(edges: .bottom)

                    // Pocket list
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(store.pockets) { pocket in
                                PocketCardView(pocket: pocket) {
                                    pocketToEdit = pocket
                                }
                                .environmentObject(store)
                            }

                            // Add pocket placeholder
                            Button {
                                showAddPocket = true
                            } label: {
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .strokeBorder(
                                                Color.white.opacity(0.4),
                                                style: StrokeStyle(
                                                    lineWidth: 2,
                                                    dash: [5, 4]
                                                )
                                            )
                                            .frame(width: 48, height: 48)
                                        Image(systemName: "plus")
                                            .font(
                                                .system(
                                                    size: 20,
                                                    weight: .medium
                                                )
                                            )
                                            .foregroundStyle(
                                                .white.opacity(0.5)
                                            )
                                    }
                                    Text("Add Pocket")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 28)
                                .background {
                                    RoundedRectangle(cornerRadius: 22)
                                        .strokeBorder(
                                            Color.white.opacity(0.22),
                                            style: StrokeStyle(
                                                lineWidth: 2,
                                                dash: [7, 5]
                                            )
                                        )
                                }
                            }
                            .buttonStyle(.plain)

                            Color.clear.frame(height: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
            }

            // ── ITEM TRAY (pinned bottom) ─────────────────────────────────
            ItemTrayView()
                .environmentObject(store)
                .padding(.horizontal, 14)
                .padding(.bottom, 36)
                .shadow(color: .black.opacity(0.18), radius: 16, y: -2)
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showAddPocket) {
            AddEditPocketView { newPocket in
                store.addPocket(newPocket)
            }
        }
        .sheet(item: $pocketToEdit) { pocket in
            AddEditPocketView(existingPocket: pocket) { updated in
                store.updatePocket(updated)
            } onDelete: {
                store.deletePocket(id: pocket.id)
            }
        }
    }
}

// MARK: - Belt

struct Belt: View {
    var body: some View {
        ZStack(alignment: .center) {
            // Belt strap
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.42, green: 0.28, blue: 0.14),
                            Color(red: 0.55, green: 0.38, blue: 0.20),
                            Color(red: 0.45, green: 0.30, blue: 0.15),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 36)
                .overlay(alignment: .top) {
                    // Top highlight stitch
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)
                }
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.black.opacity(0.15))
                        .frame(height: 1)
                }

            // Belt loops
            HStack {
                BeltLoop()
                    .padding(.leading, 28)
                Spacer()
                BeltLoop()
                    .padding(.trailing, 28)
            }
        }
    }
}

// MARK: - Belt Loop

struct BeltLoop: View {
    var body: some View {
        ZStack {
            // Loop shadow
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.black.opacity(0.3))
                .frame(width: 22, height: 44)
                .offset(x: 1, y: 1)

            // Loop body (denim coloured)
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.26, green: 0.52, blue: 0.78),
                            Color(red: 0.22, green: 0.45, blue: 0.70),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 20, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Color.black.opacity(0.35), lineWidth: 1.5)
                )

            // Stitching lines top & bottom
            VStack {
                Rectangle()
                    .fill(
                        Color(red: 0.85, green: 0.72, blue: 0.45).opacity(0.7)
                    )
                    .frame(width: 14, height: 1.5)
                    .cornerRadius(1)
                Spacer()
                Rectangle()
                    .fill(
                        Color(red: 0.85, green: 0.72, blue: 0.45).opacity(0.7)
                    )
                    .frame(width: 14, height: 1.5)
                    .cornerRadius(1)
            }
            .frame(height: 38)
        }
    }
}

// MARK: - Denim Background

struct DenimBackground: View {
    var body: some View {
        ZStack {
            // Base denim colour
            Color(red: 0.25, green: 0.50, blue: 0.76)

            // Subtle diagonal weave overlay
            Canvas { context, size in
                let spacing: CGFloat = 4
                var y: CGFloat = 0
                while y < size.height + spacing {
                    var x: CGFloat =
                        (y / spacing).truncatingRemainder(dividingBy: 2) == 0
                        ? 0 : spacing / 2
                    while x < size.width {
                        let rect = CGRect(
                            x: x,
                            y: y,
                            width: spacing * 0.6,
                            height: 1
                        )
                        context.fill(
                            Path(rect),
                            with: .color(.white.opacity(0.04))
                        )
                        x += spacing
                    }
                    y += 2
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
