//
//  RoastCategory.swift
//  BurnBook
//
//  Created by Ayush Kumar Singh on 5/20/25.
//

import Foundation

enum RoastCategory: String, CaseIterable, Identifiable {
    case auto = "Auto"
    case person = "Person"
    case object = "Object"

    var id: String { self.rawValue }
}
