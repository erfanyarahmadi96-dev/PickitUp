import SwiftUI
import MapKit

struct AddEditPocketView: View {
    var existingPocket: Pocket? = nil
    var onSave: (Pocket) -> Void
    var onDelete: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var sfSymbol: String = "bag.fill"
    @State private var selectedDays: Set<Weekday> = [.mon, .tue, .wed, .thu, .fri]
    @State private var reminderTime: Date = Pocket.defaultTime()
    @State private var location: PocketLocation? = nil

    @State private var showIconPicker = false
    @State private var showLocationPicker = false

    var isEditing: Bool { existingPocket != nil }
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && location != nil
    }

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Preview
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(.secondarySystemBackground))
                                    .frame(width: 80, height: 80)
                                Image(systemName: sfSymbol)
                                    .font(.system(size: 32))
                                    .foregroundStyle(.primary)
                            }
                            Text(name.isEmpty ? "Pocket Name" : name.uppercased())
                                .font(.headline)
                                .foregroundStyle(name.isEmpty ? .secondary : .primary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }

                // MARK: Name & Icon
                Section("Details") {
                    TextField("Pocket name (e.g. GYM, Work...)", text: $name)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)

                    Button {
                        showIconPicker = true
                    } label: {
                        HStack {
                            Image(systemName: sfSymbol)
                                .font(.title3)
                                .frame(width: 32)
                                .foregroundStyle(.primary)
                            Text("Choose Icon")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // MARK: Reminder
                Section("Reminder") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Days")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 6) {
                            ForEach(Weekday.allCases) { day in
                                DayChip(
                                    label: day.rawValue,
                                    isSelected: selectedDays.contains(day)
                                ) {
                                    if selectedDays.contains(day) {
                                        selectedDays.remove(day)
                                    } else {
                                        selectedDays.insert(day)
                                    }
                                }
                            }
                        }
                        HStack(spacing: 8) {
                            quickSelectButton("All")      { selectedDays = Set(Weekday.allCases) }
                            quickSelectButton("Weekdays") { selectedDays = [.mon, .tue, .wed, .thu, .fri] }
                            quickSelectButton("Weekends") { selectedDays = [.sat, .sun] }
                            quickSelectButton("None")     { selectedDays = [] }
                        }
                    }
                    .padding(.vertical, 4)

                    DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }

                // MARK: Location (mandatory)
                Section {
                    Button {
                        showLocationPicker = true
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(location == nil ? Color.orange.opacity(0.12) : Color.green.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                Image(systemName: location == nil ? "mappin.circle" : "mappin.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(location == nil ? .orange : .green)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(location == nil ? "Set Location" : "Change Location")
                                    .foregroundStyle(.primary)
                                    .fontWeight(.medium)
                                if location == nil {
                                    Text("Required — tap to pick on map")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                } else {
                                    Text(location!.name)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let loc = location {
                        MapPreview(coordinate: loc.coordinate, name: loc.name)
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                        Button(role: .destructive) {
                            location = nil
                        } label: {
                            HStack {
                                Spacer()
                                Label("Remove Location", systemImage: "mappin.slash")
                                Spacer()
                            }
                        }
                    }
                } header: {
                    HStack(spacing: 6) {
                        Text("Location")
                        if location == nil {
                            Text("REQUIRED")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange, in: Capsule())
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.caption)
                        }
                    }
                }

                // MARK: Delete (edit mode only)
                if isEditing, let onDelete {
                    Section {
                        Button(role: .destructive) {
                            onDelete()
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Pocket")
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
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let loc = location else { return }
                        let pocket = Pocket(
                            id: existingPocket?.id ?? UUID(),
                            name: name.trimmingCharacters(in: .whitespaces).uppercased(),
                            sfSymbol: sfSymbol,
                            days: Array(selectedDays),
                            reminderTime: reminderTime,
                            items: existingPocket?.items ?? [],
                            location: loc
                        )
                        onSave(pocket)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selected: $sfSymbol)
            }
            .sheet(isPresented: $showLocationPicker) {
                LocationPickerView(pickedLocation: $location)
            }
        }
        .onAppear { loadExisting() }
    }

    private func loadExisting() {
        guard let p = existingPocket else { return }
        name         = p.name
        sfSymbol     = p.sfSymbol
        selectedDays = Set(p.days)
        reminderTime = p.reminderTime
        location     = p.location
    }

    @ViewBuilder
    private func quickSelectButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(.tertiarySystemBackground))
                .clipShape(Capsule())
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - DayChip

struct DayChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(isSelected ? Color.primary : Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25), value: isSelected)
    }
}

// MARK: - MapPreview

struct MapPreview: View {
    let coordinate: CLLocationCoordinate2D
    let name: String

    var body: some View {
        Map(initialPosition: .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            )
        )) {
            Annotation(name, coordinate: coordinate, anchor: .bottom) {
                VStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(Color.primary)
                            .frame(width: 28, height: 28)
                        Image(systemName: "mappin")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Triangle()
                        .fill(Color.primary)
                        .frame(width: 10, height: 6)
                }
            }
        }
        .mapStyle(.standard)
        .disabled(true)
    }
}
