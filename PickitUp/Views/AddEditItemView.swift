//
//  AddEditItemView.swift
//  PickitUp
//
//  Created by Erfan Yarahmadi on 24/02/26.
//


import SwiftUI

struct AddEditItemView: View {
    // Pass nil to create, pass an item to edit
    var existingItem: PocketItem? = nil

    var onSave: (PocketItem) -> Void
    var onDelete: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var sfSymbol: String = "star.fill"
    @State private var showIconPicker = false

    var isEditing: Bool { existingItem != nil }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Preview
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(.secondarySystemBackground))
                                    .frame(width: 80, height: 80)
                                Image(systemName: sfSymbol)
                                    .font(.system(size: 34))
                                    .foregroundStyle(.primary)
                            }
                            Text(name.isEmpty ? "Item Name" : name)
                                .font(.headline)
                                .foregroundStyle(name.isEmpty ? .secondary : .primary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }

                // MARK: Name
                Section("Name") {
                    TextField("e.g. Laptop, Gym Towel…", text: $name)
                        .autocorrectionDisabled()
                }

                // MARK: Icon
                Section("Icon") {
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

                // MARK: Delete (edit mode only)
                if isEditing, let onDelete {
                    Section {
                        Button(role: .destructive) {
                            onDelete()
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Item")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Item" : "New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = PocketItem(
                            id: existingItem?.id ?? UUID(),
                            name: name.trimmingCharacters(in: .whitespaces),
                            sfSymbol: sfSymbol
                        )
                        onSave(item)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selected: $sfSymbol)
            }
        }
        .onAppear {
            if let item = existingItem {
                name = item.name
                sfSymbol = item.sfSymbol
            }
        }
    }
}