import SwiftUI

struct AddEditPocketView: View {

    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var existingPocket: Pocket? = nil
    var onSave: (Pocket) -> Void
    var onDelete: (() -> Void)? = nil

    @State private var name: String = ""
    @State private var sfSymbol: String = "bag.fill"
    @State private var selectedDays: Set<Weekday> = [.mon, .tue, .wed, .thu, .fri]
    @State private var reminderTime: Date = Pocket.defaultTime()

    @State private var showIconPicker = false
    @State private var showItemSelector = false

    @State private var selectedItemIDs: Set<UUID> = []

    var isEditing: Bool { existingPocket != nil }

    // MARK: Validation

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty
    }

    // MARK: Selected Items

    private var selectedItems: [PocketItem] {
        store.trayItems.filter { selectedItemIDs.contains($0.id) }
    }

    var body: some View {

        NavigationStack {

            Form {

                // MARK: Preview

                Section {
                    previewSection
                }

                // MARK: Details

                Section {
                    detailsSection
                }

                // MARK: Reminder

                Section {
                    reminderSection
                }

                // MARK: Items

                Section {
                    itemsSection
                }

                // MARK: Delete

                if isEditing, let onDelete {
                    Section {
                        Button(role: .destructive) {
                            onDelete()
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Pocket")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Pocket" : "New Pocket")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {

                        let orderedDays = Weekday.allCases.filter {
                            selectedDays.contains($0)
                        }

                        let pocket = Pocket(
                            id: existingPocket?.id ?? UUID(),
                            name: trimmedName.uppercased(),
                            sfSymbol: sfSymbol,
                            days: orderedDays,
                            reminderTime: reminderTime,
                            items: selectedItems
                        )

                        onSave(pocket)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }

            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selected: $sfSymbol)
            }

            .sheet(isPresented: $showItemSelector) {
                PocketItemSelectionView(selectedItemIDs: $selectedItemIDs)
                    .environmentObject(store)
            }
        }
        .onAppear {
            loadExisting()
        }
    }
}

extension AddEditPocketView {

    // MARK: Preview Section

    private var previewSection: some View {

        HStack {

            Spacer()

            VStack(spacing: 10) {

                ZStack {

                    Circle()
                        .fill(UITheme.chipBackground)
                        .frame(width: 84, height: 84)

                    Image(systemName: sfSymbol)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(UITheme.primary)
                }

                Text(name.isEmpty ? "Pocket Name" : trimmedName.uppercased())
                    .font(.headline)
                    .foregroundStyle(
                        name.isEmpty
                        ? UITheme.textSecondary
                        : UITheme.primary
                    )
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
    }

    // MARK: Details

    private var detailsSection: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("Details")
                .font(.subheadline)
                .fontWeight(.semibold)

            TextField("Pocket name (e.g. GYM, WORK...)", text: $name)
                .textInputAutocapitalization(.characters)

            Button {

                showIconPicker = true

            } label: {

                HStack {

                    Image(systemName: sfSymbol)
                        .frame(width: 28)

                    Text("Choose Icon")

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: Reminder

    private var reminderSection: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("Reminder")
                .font(.subheadline)
                .fontWeight(.semibold)

            Text("Days")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {

                ForEach(Weekday.allCases) { day in

                    DayChip(
                        label: day.rawValue,
                        isSelected: selectedDays.contains(day)
                    ) {
                        toggle(day)
                    }
                }
            }

            DatePicker(
                "Time",
                selection: $reminderTime,
                displayedComponents: .hourAndMinute
            )
        }
    }

    // MARK: Items

    private var itemsSection: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("Items")
                .font(.subheadline)
                .fontWeight(.semibold)

            Button {

                showItemSelector = true

            } label: {

                HStack {

                    Image(systemName: "square.grid.2x2.fill")

                    Text("Select Items")

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if selectedItems.isEmpty {

                Text("No items selected yet.")
                    .foregroundStyle(.secondary)

            } else {

                ScrollView(.horizontal, showsIndicators: false) {

                    HStack(spacing: 10) {

                        ForEach(selectedItems) { item in
                            ItemChip(item: item)
                        }
                    }
                }
            }
        }
    }
}

extension AddEditPocketView {

    // MARK: Helpers

    private func loadExisting() {

        guard let pocket = existingPocket else { return }

        name = pocket.name
        sfSymbol = pocket.sfSymbol
        selectedDays = Set(pocket.days)
        reminderTime = pocket.reminderTime
        selectedItemIDs = Set(pocket.items.map(\.id))
    }

    private func toggle(_ day: Weekday) {

        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}

struct DayChip: View {

    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    isSelected
                    ? UITheme.chipSelectedBackground
                    : UITheme.chipBackground
                )
                .foregroundStyle(
                    isSelected
                    ? UITheme.chipSelectedText
                    : UITheme.chipText
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
