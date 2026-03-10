//
//  PocketItemSelectionView.swift
//  PickitUp
//
//  Created by Burak Demirhan on 10/03/26.
//

import SwiftUI

struct PocketItemSelectionView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedItemIDs: Set<UUID>

    @State private var showAddItem = false
    @State private var itemToEdit: PocketItem? = nil

    var body: some View {
        NavigationStack {
            Group {
                if store.trayItems.isEmpty {
                    emptyState
                } else {
                    itemList
                }
            }
            .navigationTitle("Select Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add new item")
                    .accessibilityHint("Creates a new item to use in this pocket")
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddEditItemView { newItem in
                    store.addTrayItem(newItem)
                    selectedItemIDs.insert(newItem.id)
                }
            }
            .sheet(item: $itemToEdit) { item in
                AddEditItemView(existingItem: item) { updated in
                    store.updateTrayItem(updated)
                } onDelete: {
                    selectedItemIDs.remove(item.id)
                    store.deleteTrayItem(id: item.id)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 18) {
            Spacer()

            ZStack {
                Circle()
                    .fill(UITheme.chipBackground)
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                UITheme.primary.opacity(0.08),
                                lineWidth: 1.2
                            )
                    )

                Image(systemName: "shippingbox")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(UITheme.primary.opacity(0.65))
            }
            .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("No items available")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(UITheme.primary)

                Text("Create your essentials first, then add them to this pocket.")
                    .font(.body)
                    .foregroundStyle(UITheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }

            Button {
                showAddItem = true
            } label: {
                Label("Create First Item", systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(UITheme.buttonPrimaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(UITheme.buttonPrimaryBackground)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .accessibilityHint("Opens the screen to create your first item")

            Spacer()
        }
        .padding(.bottom, 24)
    }

    // MARK: - List

    private var itemList: some View {
        List {
            Section {
                ForEach(store.trayItems) { item in
                    itemRow(item)
                }
            } header: {
                Text("Choose items for this pocket")
                    .foregroundStyle(UITheme.textSecondary)
            } footer: {
                Text("Selected items will appear inside this pocket.")
                    .foregroundStyle(UITheme.textSecondary)
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private func itemRow(_ item: PocketItem) -> some View {
        let isSelected = selectedItemIDs.contains(item.id)

        Button {
            toggleSelection(for: item.id)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(UITheme.chipBackground)
                        .frame(width: 46, height: 46)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    UITheme.primary.opacity(0.08),
                                    lineWidth: 1
                                )
                        )

                    Image(systemName: item.sfSymbol)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(UITheme.primary)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name)
                        .font(.body)
                        .foregroundStyle(UITheme.primary)

                    Text(isSelected ? "Selected" : "Tap to select")
                        .font(.caption)
                        .foregroundStyle(isSelected ? UITheme.success : UITheme.textSecondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? UITheme.success : UITheme.textSecondary)
            }
            .contentShape(Rectangle())
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.name)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Double tap to \(isSelected ? "remove from" : "add to") this pocket")
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                itemToEdit = item
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(UITheme.info)

            Button(role: .destructive) {
                selectedItemIDs.remove(item.id)
                store.deleteTrayItem(id: item.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func toggleSelection(for id: UUID) {
        if selectedItemIDs.contains(id) {
            selectedItemIDs.remove(id)
        } else {
            selectedItemIDs.insert(id)
        }
    }
}
