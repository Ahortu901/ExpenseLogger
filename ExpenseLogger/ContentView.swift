import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\Receipt.timestamp, order: .reverse)]) private var receipts: [Receipt]

    @State private var showingAdd = false

    private var total: Decimal {
        receipts.reduce(0) { $0 + $1.claimAmount }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Total to claim")
                            .font(.headline)
                        Spacer()
                        Text(totalCurrencyString(total))
                            .font(.headline)
                    }
                }

                Section("Receipts") {
                    if receipts.isEmpty {
                        Text("No receipts yet. Tap + to add one.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(receipts) { receipt in
                            NavigationLink {
                                ReceiptDetailView(receipt: receipt)
                            } label: {
                                ReceiptRowView(receipt: receipt)
                            }
                        }
                        .onDelete(perform: deleteReceipts)
                    }
                }
            }
            .navigationTitle("Expense Logger")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    if !receipts.isEmpty {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddReceiptView()
            }
            .modelContainer(for: [Receipt.self])
        }
    }

    private func deleteReceipts(at offsets: IndexSet) {
        for index in offsets {
            let r = receipts[index]
            ReceiptImageStore.deleteImage(filename: r.imageFilename)
            modelContext.delete(r)
        }
        try? modelContext.save()
    }

    private func totalCurrencyString(_ value: Decimal) -> String {
        let ns = value as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        // You can force a currency code if needed:
        // formatter.currencyCode = "EUR"
        return formatter.string(from: ns) ?? "\(ns)"
    }
}

