//
//  EntryDetailView.swift
//  CraftJournal
//
//  Created by iMac01 on 9/29/26.
//

import SwiftUI
internal import CoreData

struct EntryDetailView: View {
    @ObservedObject var entry: CraftEntry
    @State private var showingEdit = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                if let data = entry.photo, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .cornerRadius(14)
                    
                    if let shareData = uiImage.jpegData(compressionQuality: 0.9) ?? uiImage.pngData() {
                        ShareLink(item: shareData, preview: SharePreview(entry.title ?? "Craft Photo", image: Image(uiImage: uiImage))) {
                            Label("Share Photo", systemImage: "square.and.arrow.up")
                        }
                        .padding(.bottom, 6)
                    }
                }

                if entry.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.title)
                }
                
                // Title
                Text(entry.title ?? "Untitled")
                    .font(.largeTitle)
                    .bold()
                
                if let artisan = entry.artisanName, !artisan.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "person")
                            .foregroundStyle(.secondary)
                        Text("Artisan: \(artisan)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Craft Type
                Text(entry.craftType ?? "")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                // Date
                if let date = entry.date {
                    Text(date, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Notes Section
                if let notes = entry.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOTES")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        Text(notes)
                            .font(.body)
                    }
                    .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditEntryView(entry: entry)
        }
    }
}
