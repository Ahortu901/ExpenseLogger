import SwiftUI

struct ReceiptRowView: View {
    let receipt: Receipt

    var body: some View {
        HStack(spacing: 12) {
            if let img = ReceiptImageStore.loadImage(filename: receipt.imageFilename) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.secondary.opacity(0.2))
                    .frame(width: 52, height: 52)
                    .overlay(Image(systemName: "photo"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(receipt.timestamp, style: .date)
                    .font(.subheadline)
                Text(receipt.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(currency(receipt.claimAmount))
                .font(.headline)
        }
    }

    private func currency(_ value: Decimal) -> String {
        let ns = value as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: ns) ?? "\(ns)"
    }
}
//
//  ReceiptRowView.swift
//  ExpenseLogger
//
//  Created by Derrick Ahortu on 12/01/2026.
//

