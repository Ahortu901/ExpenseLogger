import Foundation
import SwiftData

@Model
final class Receipt {
    @Attribute(.unique) var id: UUID
    var imageFilename: String        // stored on disk
    var timestamp: Date              // when saved/taken
    var claimAmount: Decimal         // user entered

    init(imageFilename: String, timestamp: Date = Date(), claimAmount: Decimal) {
        self.id = UUID()
        self.imageFilename = imageFilename
        self.timestamp = timestamp
        self.claimAmount = claimAmount
    }
}
//
//  Receipt.swift
//  ExpenseLogger
//
//  Created by Derrick Ahortu on 12/01/2026.
//

