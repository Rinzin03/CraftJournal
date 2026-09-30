
//
//  ContentView.swift
//  CraftJournal
//
//  Created by iMac01 on 9/29/26.
//

import SwiftUI
internal import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \CraftEntry.date,
                ascending: false
            )
        ],
        animation: .default
    )
    private var entries: FetchedResults<CraftEntry>

    @State private var showingAddEntry = false
    @State private var searchText = ""

    private var filteredEntries: [CraftEntry] {
        if searchText.isEmpty {
            return Array(entries)
        } else {
            return entries.filter {
                ($0.title ?? "")
                    .localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: - Entry Count
                Text("\(entries.count) \(entries.count == 1 ? "entry" : "entries")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                // MARK: - Journal Entries
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Entries Yet",
                        systemImage: "book.closed",
                        description: Text(
                            "Your craft journal is empty. Start by adding your first craft entry!"
                        )
                    )
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                } else if filteredEntries.isEmpty {
                    ContentUnavailableView(
                        "No Matching Entries",
                        systemImage: "magnifyingglass",
                        description: Text(
                            "Try searching for a different craft title."
                        )
                    )
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                } else {
                    List {
                        ForEach(filteredEntries) { entry in
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                EntryRow(entry: entry)
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(
                text: $searchText,
                prompt: "Search by title"
            )
            .navigationTitle("Craft Journal")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
                    .environment(
                        \.managedObjectContext,
                        viewContext
                    )
            }
        }
    }

    // MARK: - Delete Entries

    private func deleteEntries(offsets: IndexSet) {
        for index in offsets {
            let entry = filteredEntries[index]
            viewContext.delete(entry)
        }

        do {
            try viewContext.save()
        } catch {
            print("Could not delete: \(error)")
        }
    }
}


// MARK: - Entry Row

struct EntryRow: View {
    @ObservedObject var entry: CraftEntry

    var body: some View {
        HStack {
            if entry.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }

            if let data = entry.photo,
               let uiImage = UIImage(data: data) {

                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 8)
                    )

            } else {
                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading) {
                Text(entry.title ?? "Untitled")
                    .font(.headline)

                if let artisan = entry.artisanName,
                   !artisan.isEmpty {

                    Text("Artisan: \(artisan)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(entry.craftType ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}


// MARK: - Preview

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.preview.container.viewContext
        )
}

