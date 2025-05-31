//
//  SavedRoast.swift
//  BurnBook
//
//  Created by Ayush Kumar Singh on 13/03/25.
//

import Foundation

struct SavedRoast: Identifiable, Codable {
    let id: UUID
    let nameToRoast: String
    let roastText: String
    let dateCreated: Date
    
    init(nameToRoast: String, roastText: String) {
        self.id = UUID()
        self.nameToRoast = nameToRoast
        self.roastText = roastText
        self.dateCreated = Date()
    }
}

class RoastCollection: ObservableObject {
    @Published var savedRoasts: [SavedRoast] = []
    
    private let userDefaults = UserDefaults.standard
    private let savedRoastsKey = "SavedRoasts"
    
    init() {
        loadRoasts()
    }
    
    func saveRoast(_ roast: SavedRoast) {
        savedRoasts.insert(roast, at: 0) // Add to beginning
        saveToUserDefaults()
    }
    
    func deleteRoast(_ roast: SavedRoast) {
        savedRoasts.removeAll { $0.id == roast.id }
        saveToUserDefaults()
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(savedRoasts) {
            userDefaults.set(encoded, forKey: savedRoastsKey)
        }
    }
    
    private func loadRoasts() {
        if let data = userDefaults.data(forKey: savedRoastsKey),
           let decoded = try? JSONDecoder().decode([SavedRoast].self, from: data) {
            savedRoasts = decoded
        }
    }
}
