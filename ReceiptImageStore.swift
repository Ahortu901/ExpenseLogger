import UIKit

enum ReceiptImageStore {
    static func receiptsDirectory() throws -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("receipts", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func saveJPEG(_ image: UIImage, quality: CGFloat = 0.85) throws -> String {
        let filename = UUID().uuidString + ".jpg"
        let dir = try receiptsDirectory()
        let url = dir.appendingPathComponent(filename)

        guard let data = image.jpegData(compressionQuality: quality) else {
            throw NSError(domain: "ReceiptImageStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JPEG"])
        }
        try data.write(to: url, options: [.atomic])
        return filename
    }

    static func loadImage(filename: String) -> UIImage? {
        do {
            let dir = try receiptsDirectory()
            let url = dir.appendingPathComponent(filename)
            return UIImage(contentsOfFile: url.path)
        } catch {
            return nil
        }
    }

    static func deleteImage(filename: String) {
        do {
            let dir = try receiptsDirectory()
            let url = dir.appendingPathComponent(filename)
            try? FileManager.default.removeItem(at: url)
        } catch { }
    }
}
//
//  ReceiptImageStore.swift
//  ExpenseLogger
//
//  Created by Derrick Ahortu on 12/01/2026.
//

