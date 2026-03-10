//
//  AddEditItemView.swift
//  PickitUp
//
//  Created by Erfan Yarahmadi on 24/02/26.
//

import SwiftUI

struct AddEditItemView: View {
    var existingItem: PocketItem? = nil
    
    var onSave: (PocketItem) -> Void
    var onDelete: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var sfSymbol: String = "star.fill"
    @State private var showIconPicker = false
    
    var isEditing: Bool { existingItem != nil }
    
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
                        
                        VStack(spacing: 12) {
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
                                    .font(.system(size: 34, weight: .medium))
                                    .foregroundStyle(UITheme.primary)
                            }
                            .accessibilityHidden(true)
                            
                            Text(name.isEmpty ? "Item Name" : trimmedName)
                                .font(.headline)
                                .foregroundStyle(name.isEmpty ? UITheme.textSecondary : UITheme.primary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                // MARK: Name
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(UITheme.primary)
                        
                        TextField("e.g. Laptop, Gym Towel", text: $name)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .foregroundStyle(UITheme.primary)
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: Icon
                Section {
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
                                
                                Text("Pick a symbol for this item")
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
                } header: {
                    Text("Icon")
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
                                Text("Delete Item")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.automatic)
            .navigationTitle(isEditing ? "Edit Item" : "New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = PocketItem(
                            id: existingItem?.id ?? UUID(),
                            name: trimmedName,
                            sfSymbol: sfSymbol
                        )
                        onSave(item)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                    .accessibilityHint("Saves this item")
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
