import SwiftUI
import PhotosUI
import SwiftData

struct AddReceiptView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?

    @State private var amountText: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Receipt photo") {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack {
                            Image(systemName: "camera")
                            Text(selectedUIImage == nil ? "Select receipt photo" : "Change photo")
                        }
                    }

                    if let uiImage = selectedUIImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 260)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Text("No photo selected yet.")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Claim amount") {
                    TextField("e.g. 12.50", text: $amountText)
                        .keyboardType(.decimalPad)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Receipt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Saving..." : "Save") {
                        saveReceipt()
                    }
                    .disabled(isSaving)
                }
            }
            .onChange(of: selectedItem) { _, newValue in
                guard let newValue else { return }
                Task { await loadImage(from: newValue) }
            }
        }
    }

    private func loadImage(from item: PhotosPickerItem) async {
        errorMessage = nil
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    self.selectedUIImage = image
                }
            } else {
                await MainActor.run { self.errorMessage = "Could not load that image." }
            }
        } catch {
            await MainActor.run { self.errorMessage = "Image load failed: \(error.localizedDescription)" }
        }
    }

    private func saveReceipt() {
        errorMessage = nil

        guard let image = selectedUIImage else {
            errorMessage = "Please select a receipt photo."
            return
        }

        // Parse amount safely
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        guard let decimal = Decimal(string: normalized), decimal >= 0 else {
            errorMessage = "Enter a valid amount (e.g. 12.50)."
            return
        }

        isSaving = true
        do {
            let filename = try ReceiptImageStore.saveJPEG(image)
            let receipt = Receipt(imageFilename: filename, timestamp: Date(), claimAmount: decimal)
            modelContext.insert(receipt)
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Save failed: \(error.localizedDescription)"
        }
        isSaving = false
    }
}
//
//  AddReceiptView.swift
//  ExpenseLogger
//
//  Created by Derrick Ahortu on 12/01/2026.
//

