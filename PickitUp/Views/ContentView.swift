import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()

    @State private var showAddPocket = false
    @State private var pocketToEdit: Pocket? = nil
    @State private var showItemsManager = false
    @State private var leavingPocket: Pocket?

    private var today: Weekday {
        let weekdayNumber = Calendar.current.component(.weekday, from: Date())
        switch weekdayNumber {
        case 1: return .sun
        case 2: return .mon
        case 3: return .tue
        case 4: return .wed
        case 5: return .thu
        case 6: return .fri
        default: return .sat
        }
    }

    private var todaysPockets: [Pocket] {
        store.pockets.filter { $0.days.contains(today) }
    }

    private var checkedPocketCount: Int {
        todaysPockets.filter { !$0.items.isEmpty }.count
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                
                // ── WAISTBAND / HEADER ────────────────────────────────────
                ZStack(alignment: .bottom) {
                    Color(.systemGray6)
                        .ignoresSafeArea(edges: .top)
                    
                    VStack(spacing: 0) {
                        HStack(alignment: .center, spacing: 10) {
                            Text("Pockets")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(
                                    .primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            
                            Spacer()
                            
                            Button {
                                showAddPocket = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.subheadline.weight(.bold))
                                    
                                    Text("New Pocket")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundStyle(UITheme.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(UITheme.surface.opacity(0.92), in: Capsule())
                                .shadow(color: .black.opacity(0.07), radius: 6, y: 2)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Create new pocket")
                            .accessibilityHint("Opens the screen to create a new pocket")
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 14)
                        
                        Belt()
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                
                // ── BODY ──────────────────────────────────────────────────
                ZStack {
                    DenimBackground()
                        .ignoresSafeArea(edges: .bottom)
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            todaysCheckSection
                            
                            if !store.pockets.isEmpty {
                                sectionHeader("All Pockets")
                            }
                            
                            ForEach(store.pockets) { pocket in
                                PocketCardView(pocket: pocket) {
                                    pocketToEdit = pocket
                                }
                                .environmentObject(store)
                            }
                            
                            Button {
                                showAddPocket = true
                            } label: {
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .strokeBorder(
                                                UITheme.textOnDark.opacity(0.4),
                                                style: StrokeStyle(lineWidth: 2, dash: [5, 4])
                                            )
                                            .frame(width: 48, height: 48)
                                        
                                        Image(systemName: "plus")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundStyle(UITheme.textOnDark.opacity(0.7))
                                    }
                                    
                                    Text("Add Pocket")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(UITheme.textOnDark.opacity(0.85))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 28)
                                .background {
                                    RoundedRectangle(cornerRadius: 22)
                                        .strokeBorder(
                                            UITheme.textOnDark.opacity(0.28),
                                            style: StrokeStyle(lineWidth: 2, dash: [7, 5])
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Add pocket")
                            .accessibilityHint("Opens the create pocket screen")
                            
                            Color.clear.frame(height: 110)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
            }
            
            // MARK: Test Notification Button
            
            
            Button {
                showItemsManager = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Items")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(UITheme.buttonPrimaryText)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(UITheme.buttonPrimaryBackground)
                )
                .shadow(color: .black.opacity(0.22), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 20)
            .padding(.bottom, 32)
            .accessibilityLabel("Open items")
            .accessibilityHint("Opens your saved items")
        }
        .ignoresSafeArea(edges: .bottom)
        
        .sheet(isPresented: $showAddPocket) {
            AddEditPocketView { newPocket in
                store.addPocket(newPocket)
            }
            .environmentObject(store)
        }
        
        .sheet(item: $pocketToEdit) { pocket in
            AddEditPocketView(existingPocket: pocket) { updated in
                store.updatePocket(updated)
            } onDelete: {
                store.deletePocket(id: pocket.id)
            }
            .environmentObject(store)
        }
        
        .sheet(isPresented: $showItemsManager) {
            ItemsManagerView()
                .environmentObject(store)
                .presentationDetents([.medium, .large])
        }
        
        .sheet(item: $leavingPocket) { pocket in
            LeavingModeView(pocket: pocket)
        }
        
        .onAppear {
            openLeavingPocketIfNeeded()
        }
    }
    // MARK: - Today Section

    private var todaysCheckSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(UITheme.surface.opacity(0.18))
                        .frame(width: 46, height: 46)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(UITheme.textOnDark.opacity(0.14), lineWidth: 1)
                        )

                    Image(systemName: todaysPockets.isEmpty ? "calendar" : "checklist")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(UITheme.textOnDark)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Today’s Check")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(UITheme.textOnDark)

                    Text(heroSubtitle)
                        .font(.footnote)
                        .foregroundStyle(UITheme.textOnDark.opacity(0.78))
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                summaryPill(
                    title: "Today",
                    value: today.full,
                    systemImage: "sun.max.fill"
                )

                summaryPill(
                    title: "Active",
                    value: "\(todaysPockets.count)",
                    systemImage: "tray.full.fill"
                )

                summaryPill(
                    title: "Ready",
                    value: "\(checkedPocketCount)",
                    systemImage: "checkmark.circle.fill"
                )
            }

            if todaysPockets.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No pockets scheduled for today.")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(UITheme.textOnDark)

                    Text("Create a pocket and choose days so PickitUP can remind you before you leave.")
                        .font(.footnote)
                        .foregroundStyle(UITheme.textOnDark.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .background(UITheme.surface.opacity(0.14), in: RoundedRectangle(cornerRadius: 18))
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Scheduled Today")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(UITheme.textOnDark.opacity(0.92))
                        .textCase(.uppercase)

                    ForEach(todaysPockets.prefix(3)) { pocket in
                        Button {
                            pocketToEdit = pocket
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(UITheme.surface.opacity(0.16))
                                        .frame(width: 40, height: 40)

                                    Image(systemName: pocket.sfSymbol)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(UITheme.textOnDark)
                                }
                                .accessibilityHidden(true)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(pocket.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(UITheme.textOnDark)

                                    Text(pocket.reminderTimeString)
                                        .font(.caption)
                                        .foregroundStyle(UITheme.textOnDark.opacity(0.82))
                                }

                                Spacer()

                                statusBadge(for: pocket)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(UITheme.surface.opacity(0.14), in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(pocket.name), \(pocket.reminderTimeString)")
                        .accessibilityHint("Opens this pocket for editing")
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [
                            UITheme.primary.opacity(0.22),
                            UITheme.primary.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(UITheme.textOnDark.opacity(0.16), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .contain)
    }

    private var heroSubtitle: String {
        if todaysPockets.isEmpty {
            return "Nothing is scheduled yet. Build a pocket and create a leaving routine."
        }

        if checkedPocketCount == todaysPockets.count {
            return "Everything for today looks ready."
        }

        return "Check today’s essentials before you head out."
    }
    
    private func openLeavingPocketIfNeeded() {
        guard
            let id = NotificationDelegate.sharedPocketID,
            let uuid = UUID(uuidString: id),
            let pocket = store.pockets.first(where: { $0.id == uuid })
        else { return }

        leavingPocket = pocket
        NotificationDelegate.sharedPocketID = nil
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(UITheme.textOnDark.opacity(0.94))
            Spacer()
        }
        .padding(.top, 4)
        .padding(.bottom, 2)
        .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private func summaryPill(title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(UITheme.textOnDark)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(UITheme.textOnDark.opacity(0.82))

                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(UITheme.textOnDark)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(UITheme.surfaceSoft, in: Capsule())
    }

    @ViewBuilder
    private func statusBadge(for pocket: Pocket) -> some View {
        let isReady = !pocket.items.isEmpty

        Text(isReady ? "Ready" : "Empty")
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(isReady ? UITheme.success : UITheme.warning)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(UITheme.surfaceSoft)
            )
    }
}

// MARK: - Belt

struct Belt: View {
    var body: some View {
        ZStack(alignment: .center) {
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
                    Rectangle()
                        .fill(UITheme.textOnDark.opacity(0.08))
                        .frame(height: 1)
                }
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.black.opacity(0.15))
                        .frame(height: 1)
                }

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
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.black.opacity(0.3))
                .frame(width: 22, height: 44)
                .offset(x: 1, y: 1)

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

            VStack {
                Rectangle()
                    .fill(Color(red: 0.85, green: 0.72, blue: 0.45).opacity(0.7))
                    .frame(width: 14, height: 1.5)
                    .cornerRadius(1)

                Spacer()

                Rectangle()
                    .fill(Color(red: 0.85, green: 0.72, blue: 0.45).opacity(0.7))
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
            UITheme.denim

            Canvas { context, size in
                let spacing: CGFloat = 4
                var y: CGFloat = 0

                while y < size.height + spacing {
                    var x: CGFloat =
                        (y / spacing).truncatingRemainder(dividingBy: 2) == 0
                        ? 0
                        : spacing / 2

                    while x < size.width {
                        let rect = CGRect(
                            x: x,
                            y: y,
                            width: spacing * 0.6,
                            height: 1
                        )
                        context.fill(
                            Path(rect),
                            with: .color(UITheme.textOnDark.opacity(0.04))
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
