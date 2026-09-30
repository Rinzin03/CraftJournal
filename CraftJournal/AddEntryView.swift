//
//  AddEntryView.swift
//  CraftJournal
//
//  Created by iMac01 on 9/29/26.
//

import SwiftUI
import PhotosUI
internal import CoreData

struct AddEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    // Define your craft options here so crafts[0] is always safe and valid
    private let crafts = ["Shingzo", "Dozo", "Parzo", "Lhazo", "Jinzo", "Lugzo", "Garzo",
    "Troeko", "Tsharzo", "Thagzo", "Tshemzo", "Shagzo", "Deh-sho"]

    @State private var title = ""
    @State private var artisanName = ""
    @State private var craftType = "Thagzo"
    @State private var notes = "" // Added notes state property
    @State private var isFavorite = false
    @State private var image: UIImage?
    @State private var showingCamera = false
    @State private var selectedPhoto: PhotosPickerItem? = nil

    private let navy = Color(
        red: 0.04,
        green: 0.10,
        blue: 0.20
    )

    var body: some View {
        NavigationStack {
            ZStack {
                Color(
                    red: 0.96,
                    green: 0.97,
                    blue: 0.99
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("New Craft Entry")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(navy)

                            Text("Document a piece of traditional craft")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 10)

                        // Title
                        VStack(alignment: .leading, spacing: 10) {
                            Text("CRAFT TITLE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(navy)

                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundStyle(navy)

                                TextField(
                                    "Enter craft title",
                                    text: $title
                                )
                                .textInputAutocapitalization(.words)
                            }
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 14)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        navy.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                        }

                        // Artisan Name
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ARTISAN NAME")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(navy)

                            HStack {
                                Image(systemName: "person")
                                    .foregroundStyle(navy)

                                TextField(
                                    "Enter artisan name",
                                    text: $artisanName
                                )
                                .textInputAutocapitalization(.words)
                            }
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 14)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        navy.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                        }

                        // Craft type selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CRAFT TYPE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(navy)

                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ],
                                spacing: 12
                            ) {
                                ForEach(crafts, id: \.self) { craft in
                                    Button {
                                        craftType = craft
                                    } label: {
                                        HStack {
                                            Text(craft)
                                                .font(.subheadline)
                                                .fontWeight(.medium)

                                            Spacer()

                                            if craftType == craft {
                                                Image(
                                                    systemName:
                                                        "checkmark.circle.fill"
                                                )
                                            }
                                        }
                                        .foregroundStyle(
                                            craftType == craft
                                            ? .white
                                            : navy
                                        )
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            craftType == craft
                                            ? navy
                                            : Color.white
                                        )
                                        .clipShape(
                                            RoundedRectangle(
                                                cornerRadius: 12
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(
                                                cornerRadius: 12
                                            )
                                            .stroke(
                                                navy.opacity(0.15),
                                                lineWidth: 1
                                            )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Notes Section (Editable Text Field)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("NOTES (OPTIONAL)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(navy)

                            TextField(
                                "Enter any additional notes",
                                text: $notes,
                                axis: .vertical
                            )
                            .lineLimit(3...6)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 14)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        navy.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                        }

                        Toggle(isOn: $isFavorite) {
                            HStack {
                                Image(systemName: isFavorite ? "star.fill" : "star")
                                    .foregroundStyle(isFavorite ? .yellow : .gray)
                                Text("Mark as Favorite")
                            }
                        }
                        .tint(.yellow)

                        // Photo Section Added Below Picker/Inputs
                        Section("Photo") {
                            if let image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 250)
                            }
                            Button("Take Photo") {
                                showingCamera = true
                            }
                            PhotosPicker(
                                selection: $selectedPhoto,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
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
                        .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                        // Save button
                        Button {
                            saveEntry()
                        } label: {
                            HStack {
                                Image(
                                    systemName: "square.and.arrow.down.fill"
                                )

                                Text("Save Entry")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                        .foregroundStyle(.white)
                        .background(
                            title.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty
                            ? Color.gray
                            : navy
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: 14)
                        )
                        .disabled(
                            title.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Add Entry")
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(image: $image)
                    .ignoresSafeArea()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(navy)
                }
            }
        }
    }

    private func saveEntry() {
        let cleanedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedTitle.isEmpty else {
            return
        }

        let entry = CraftEntry(context: viewContext)

        entry.id = UUID()
        entry.title = cleanedTitle
        entry.artisanName = artisanName
        entry.craftType = craftType
        entry.date = Date()
        entry.notes = notes // Assigned notes to Core Data entity
        entry.isFavorite = isFavorite
        entry.photo = image?.jpegData(compressionQuality: 1.0)

        do {
            try viewContext.save()
            print("ENTRY SAVED SUCCESSFULLY TO DISK")
            dismiss()
        } catch {
            print("COULD NOT SAVE ENTRY: \(error.localizedDescription)")
        }
    }
}

