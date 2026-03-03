//
//  IconPickerView.swift
//  PickitUp
//
//  Created by Erfan Yarahmadi on 24/02/26.
//


import SwiftUI

struct IconPickerView: View {
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedCategory: IconCategory? = nil

    private var categories: [IconCategory] { IconLibrary.all }

    private var displayedCategories: [IconCategory] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if query.isEmpty {
            if let cat = selectedCategory {
                return [cat]
            }
            return categories
        }
        // Search across all categories
        return categories.compactMap { cat in
            let filtered = cat.symbols.filter {
                $0.name.lowercased().contains(query) ||
                $0.symbol.lowercased().contains(query)
            }
            return filtered.isEmpty ? nil : IconCategory(name: cat.name, symbols: filtered)
        }
    }

    // Grid columns
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search icons…", text: $searchText)
                        .autocorrectionDisabled()
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

                // Category chips (hidden during search)
                if searchText.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            chip(title: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            ForEach(categories) { cat in
                                chip(title: cat.name, isSelected: selectedCategory?.id == cat.id) {
                                    selectedCategory = cat
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                    }
                }

                Divider()

                // Icon grid
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20, pinnedViews: [.sectionHeaders]) {
                        ForEach(displayedCategories) { category in
                            Section {
                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(category.symbols) { sym in
                                        iconCell(sym)
                                    }
                                }
                                .padding(.horizontal, 16)
                            } header: {
                                Text(category.name)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                    .textCase(.uppercase)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.background)
                            }
                        }
                        Color.clear.frame(height: 20)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: Sub-views

    @ViewBuilder
    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.primary : Color(.secondarySystemBackground))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func iconCell(_ sym: IconSymbol) -> some View {
        let isSelected = selected == sym.symbol
        Button {
            selected = sym.symbol
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { dismiss() }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: sym.symbol)
                    .font(.system(size: 22))
                    .frame(width: 48, height: 48)
                    .background(isSelected ? Color.primary : Color(.secondarySystemBackground))
                    .foregroundStyle(isSelected ? Color(.systemBackground) : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.primary : .clear, lineWidth: 2)
                    )
                Text(sym.name)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
    }
}
