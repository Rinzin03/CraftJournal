// EditEntryView.swift
// CraftJournal

import SwiftUI
import PhotosUI
internal import CoreData

struct EditEntryView: View {
    @ObservedObject var entry: CraftEntry
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var artisanName: String
    @State private var craftType: String
    @State private var notes: String
    @State private var isFavorite: Bool
    @State private var image: UIImage?
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showingCamera = false

    private let crafts = ["Shingzo", "Dozo", "Parzo", "Lhazo", "Jinzo", "Lugzo", "Garzo",
        "Troeko", "Tsharzo", "Thagzo", "Tshemzo", "Shagzo", "Deh-sho"]
    private let navy = Color(red: 0.04, green: 0.10, blue: 0.20)

    init(entry: CraftEntry) {
        self.entry = entry
        let entryTitle = (entry.value(forKey: "title") as? String) ?? ""
        let entryArtisan = (entry.value(forKey: "artisanName") as? String) ?? ""
        let entryCraft = (entry.value(forKey: "craftType") as? String) ?? "Thagzo"
        let entryNotes = (entry.value(forKey: "notes") as? String) ?? ""
        let entryFavorite = (entry.value(forKey: "isFavorite") as? Bool) ?? false
        _title = State(initialValue: entryTitle)
        _artisanName = State(initialValue: entryArtisan)
        _craftType = State(initialValue: entryCraft)
        _notes = State(initialValue: entryNotes)
        _isFavorite = State(initialValue: entryFavorite)
        if let data = entry.photo, let uiImage = UIImage(data: data) {
            _image = State(initialValue: uiImage)
        } else {
            _image = State(initialValue: nil)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CRAFT TITLE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(navy)
                        HStack {
                            Image(systemName: "pencil").foregroundStyle(navy)
                            TextField("Enter craft title", text: $title)
                                .textInputAutocapitalization(.words)
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(navy.opacity(0.15), lineWidth: 1))
                    }
                    // Artisan Name
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ARTISAN NAME")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(navy)
                        HStack {
                            Image(systemName: "person").foregroundStyle(navy)
                            TextField("Enter artisan name", text: $artisanName)
                                .textInputAutocapitalization(.words)
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(navy.opacity(0.15), lineWidth: 1))
                    }
                    // Craft type selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CRAFT TYPE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(navy)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(crafts, id: \.self) { craft in
                                Button {
                                    craftType = craft
                                } label: {
                                    HStack {
                                        Text(craft).font(.subheadline).fontWeight(.medium)
                                        Spacer()
                                        if craftType == craft {
                                            Image(systemName: "checkmark.circle.fill")
                                        }
                                    }
                                    .foregroundStyle(craftType == craft ? .white : navy)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(craftType == craft ? navy : Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(navy.opacity(0.15), lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    // Notes
                    VStack(alignment: .leading, spacing: 10) {
                        Text("NOTES (OPTIONAL)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(navy)
                        TextField("", text: $notes, prompt: Text("Feel free to jot down any thoughts"), axis: .vertical)
                            .lineLimit(3...6)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(navy.opacity(0.15), lineWidth: 1))
                        if notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("You can leave this blank and add notes anytime.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    // Favorite toggle
                    Toggle(isOn: $isFavorite) {
                        HStack {
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .foregroundStyle(isFavorite ? .yellow : .gray)
                            Text("Mark as Favorite")
                        }
                    }
                    .tint(.yellow)
                    // Photo section
                    Section("Photo") {
                        if let image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 250)
                        }
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button("Take Photo") { showingCamera = true }
                        } else {
                            Button("Camera Unavailable") {}
                                .disabled(true)
                        }
                        PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("Choose from Library")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .onChange(of: selectedPhoto) { oldValue, newValue in
                            if let item = newValue {
                                Task {
                                    if let data = try? await item.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                                        image = uiImage
                                    }
                                }
                            }
                        }
                    }
                    // Save button
                    Button {
                        saveChanges()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Save Changes")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .foregroundStyle(.white)
                    .background(navy)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .navigationTitle("Edit Entry")
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(image: $image).ignoresSafeArea()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(navy)
                }
            }
        }
    }

    private func saveChanges() {
        // Trim and validate title
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTitle.isEmpty else { return }

        // Assign updated values to the managed object. Avoid using any projected bindings like `$entry`.
        entry.setValue(cleanedTitle, forKey: "title")
        entry.setValue(artisanName, forKey: "artisanName")
        entry.setValue(craftType, forKey: "craftType")
        entry.setValue(notes, forKey: "notes")
        entry.setValue(isFavorite, forKey: "isFavorite")

        // Preserve existing date or set if missing
        if entry.value(forKey: "date") as? Date == nil {
            entry.setValue(Date(), forKey: "date")
        }

        // Persist photo data if present
        if let img = image, let data = img.jpegData(compressionQuality: 1.0) {
            entry.setValue(data, forKey: "photo")
        }

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Could not update entry: \(error)")
        }
    }
}

