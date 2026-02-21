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
                    .submitLabel(.done)
                    .onSubmit {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        updateAmount()
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                        }
                    }

                Button("Update amount") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        updateAmount()
                    }
                }
            }

            Section {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                } else {
                    Color.clear.frame(height: 0)
                }
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

