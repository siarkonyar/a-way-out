//
//  AppGroup.swift
//  A Way Out
//

import Foundation
import FamilyControls

struct AppGroup: Identifiable, Codable {
    let id: UUID
    var name: String
    var selection: FamilyActivitySelection

    init(id: UUID = UUID(), name: String, selection: FamilyActivitySelection = FamilyActivitySelection()) {
        self.id = id
        self.name = name
        self.selection = selection
    }
}
