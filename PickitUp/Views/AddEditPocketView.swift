import SwiftUI

struct AddEditPocketView: View {
    var existingPocket: Pocket? = nil
    var onSave: (Pocket) -> Void
    var onDelete: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var sfSymbol: String = "bag.fill"
    @State private var selectedDays: Set<Weekday> = [.mon, .tue, .wed, .thu, .fri]
    @State private var reminderTime: Date = Pocket.defaultTime()
    
    @State private var showIconPicker = false
    
    var isEditing: Bool { existingPocket != nil }
    
    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var canSave: Bool {
        !trimmedName.isEmpty
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
                                    .fill(UITheme.chipBackground)
                                    .frame(width: 84, height: 84)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                UITheme.primary.opacity(0.10),
                                                lineWidth: 1.2
                                            )
                                    )
                                
                                Image(systemName: sfSymbol)
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundStyle(UITheme.primary)
                            }
                            .accessibilityHidden(true)
                            
                            Text(name.isEmpty ? "Pocket Name" : trimmedName.uppercased())
                                .font(.headline)
                                .foregroundStyle(name.isEmpty ? UITheme.textSecondary : UITheme.primary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                // MARK: Details
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(UITheme.primary)
                        
                        TextField("Pocket name (e.g. GYM, WORK...)", text: $name)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .foregroundStyle(UITheme.primary)
                        
                        Button {
                            showIconPicker = true
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(UITheme.chipBackground)
                                        .frame(width: 38, height: 38)
                                    
                                    Image(systemName: sfSymbol)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundStyle(UITheme.primary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Choose Icon")
                                        .font(.body)
                                        .foregroundStyle(UITheme.primary)
                                    
                                    Text("Pick a symbol for this pocket")
                                        .font(.caption)
                                        .foregroundStyle(UITheme.textSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(UITheme.textSecondary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Opens the icon picker")
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: Reminder
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reminder")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(UITheme.primary)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Days")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(UITheme.textSecondary)
                            
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
                            
                            HStack(spacing: 8) {
                                quickSelectButton("All") {
                                    selectedDays = Set(Weekday.allCases)
                                }
                                
                                quickSelectButton("Weekdays") {
                                    selectedDays = [.mon, .tue, .wed, .thu, .fri]
                                }
                                
                                quickSelectButton("Weekends") {
                                    selectedDays = [.sat, .sun]
                                }
                                
                                quickSelectButton("None") {
                                    selectedDays = []
                                }
                            }
                        }
                        
                        DatePicker(
                            "Time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .tint(UITheme.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quick Time Presets")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(UITheme.textSecondary)
                            
                            HStack(spacing: 8) {
                                quickSelectButton("Morning") {
                                    reminderTime = makeTime(hour: 8, minute: 0)
                                }
                                
                                quickSelectButton("Work") {
                                    reminderTime = makeTime(hour: 8, minute: 30)
                                }
                                
                                quickSelectButton("School") {
                                    reminderTime = makeTime(hour: 7, minute: 30)
                                }
                                
                                quickSelectButton("Evening") {
                                    reminderTime = makeTime(hour: 18, minute: 0)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: Existing Items
                if isEditing {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Items")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(UITheme.primary)
                            
                            if let items = existingPocket?.items, !items.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(items) { item in
                                            ItemChip(item: item)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            } else {
                                Text("No items added yet.")
                                    .font(.body)
                                    .foregroundStyle(UITheme.textSecondary)
                            }
                            
                            Text("Item selection will be improved in the next step.")
                                .font(.footnote)
                                .foregroundStyle(UITheme.textSecondary)
                        }
                        .padding(.vertical, 4)
                    }
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
                        let orderedDays = Weekday.allCases.filter { selectedDays.contains($0) }
                        
                        let pocket = Pocket(
                            id: existingPocket?.id ?? UUID(),
                            name: trimmedName.uppercased(),
                            sfSymbol: sfSymbol,
                            days: orderedDays,
                            reminderTime: reminderTime,
                            items: existingPocket?.items ?? []
                        )
                        
                        onSave(pocket)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                    .accessibilityHint("Saves this pocket")
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selected: $sfSymbol)
            }
        }
        .onAppear {
            loadExisting()
        }
    }
    
    // MARK: Helpers
    
    private func loadExisting() {
        guard let pocket = existingPocket else { return }
        name = pocket.name
        sfSymbol = pocket.sfSymbol
        selectedDays = Set(pocket.days)
        reminderTime = pocket.reminderTime
    }
    
    private func toggle(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
    
    private func makeTime(hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
    
    @ViewBuilder
    private func quickSelectButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(UITheme.chipBackground)
                .clipShape(Capsule())
                .foregroundStyle(UITheme.chipText)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
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
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(
                    isSelected
                    ? UITheme.chipSelectedText
                    : UITheme.chipText
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    isSelected
                    ? UITheme.chipSelectedBackground
                    : UITheme.chipBackground
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            isSelected
                            ? UITheme.chipSelectedBackground
                            : UITheme.primary.opacity(0.08),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25), value: isSelected)
        .accessibilityLabel(label)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}
