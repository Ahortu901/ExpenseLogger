import SwiftUI
import SwiftData

struct ReceiptDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var amountText: String = ""
    @State private var errorMessage: String?

    let receipt: Receipt

    var body: some View {
        Form {
            Section("Receipt") {
                if let img = ReceiptImageStore.loadImage(filename: receipt.imageFilename) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 360)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Text("Image missing.")
                        .foregroundStyle(.secondary)
                }

                Text("Saved: \(receipt.timestamp.formatted(date: .abbreviated, time: .shortened))")
                    .foregroundStyle(.secondary)
            }

            Section("Claim amount") {
                TextField("e.g. 12.50", text: $amountText)
                    .keyboardType(.decimalPad)

                Button("Update amount") {
                    updateAmount()
                }
            }

            if let errorMessage {
                Section { Text(errorMessage).foregroundStyle(.red) }
            }
        }
        .navigationTitle("Receipt")
        .onAppear {
            amountText = "\(receipt.claimAmount)"
        }
    }

    private func updateAmount() {
        errorMessage = nil
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        guard let decimal = Decimal(string: normalized), decimal >= 0 else {
            errorMessage = "Enter a valid amount."
            return
        }
        receipt.claimAmount = decimal
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Update failed: \(error.localizedDescription)"
        }
    }
}
//
//  ReceiptDetailView.swift
//  ExpenseLogger
//
//  Created by Derrick Ahortu on 12/01/2026.
//

