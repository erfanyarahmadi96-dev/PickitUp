//
//  ItemsManagerView.swift
//  PickitUp
//
//  Created by Burak Demirhan on 09/03/26.
//


import SwiftUI

struct ItemsManagerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var activeSheet: ActiveSheet?

    var body: some View {
        NavigationStack {
            Group {
                if store.trayItems.isEmpty {
                    emptyState
                } else {
                    itemList
                }
            }
            .navigationTitle("Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        activeSheet = .add
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add new item")
                    .accessibilityHint("Opens the screen to create a new item")
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .add:
                    AddEditItemView { newItem in
                        store.addTrayItem(newItem)
                    }

                case .edit(let item):
                    AddEditItemView(existingItem: item) { updated in
                        store.updateTrayItem(updated)
                    } onDelete: {
                        store.deleteTrayItem(id: item.id)
                    }
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

                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(UITheme.primary.opacity(0.65))
            }
            .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("No items yet")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(UITheme.primary)

                Text("Create the things you never want to forget, then add them to your pockets.")
                    .font(.body)
                    .foregroundStyle(UITheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }

            Button {
                activeSheet = .add
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
                    Button {
                        activeSheet = .edit(item)
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

                                Text("Tap to edit")
                                    .font(.caption)
                                    .foregroundStyle(UITheme.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(UITheme.textSecondary)
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(item.name)
                    .accessibilityHint("Opens item details for editing")
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            store.deleteTrayItem(id: item.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            activeSheet = .edit(item)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(UITheme.info)
                    }
                }
            } header: {
                Text("Your Essentials")
                    .foregroundStyle(UITheme.textSecondary)
            } footer: {
                Text("These items can be reused across different pockets.")
                    .foregroundStyle(UITheme.textSecondary)
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - ActiveSheet

private enum ActiveSheet: Identifiable {
    case add
    case edit(PocketItem)

    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let item):
            return "edit-\(item.id.uuidString)"
        }
    }
}
