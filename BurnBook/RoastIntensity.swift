//
//  RoastIntensity.swift
//  BurnBook
//
//  Created by Ayush Kumar Singh on 5/20/25.
//

import Foundation

enum RoastIntensity: String, CaseIterable, Identifiable {
    case friendly = "Friendly"
    case homicidal = "Homicidal"  
    case overkill = "Overkill"

    var id: String { self.rawValue }
    
    var sliderValue: Double {
        switch self {
        case .friendly: return 0.0
        case .homicidal: return 1.0
        case .overkill: return 2.0
        }
    }
    
    static func from(sliderValue: Double) -> RoastIntensity {
        switch sliderValue {
        case 0.0..<0.5: return .friendly
        case 0.5..<1.5: return .homicidal
        default: return .overkill
        }
    }
}
