//
//  AppState.swift
//  A Way Out
//

import Foundation
import Combine

final class AppState: ObservableObject {
    static let shared = AppState()

    @Published private(set) var assignedTagUID: String?

    private let uidKey = "assignedTagUID"

    private init() {
        assignedTagUID = UserDefaults.standard.string(forKey: uidKey)
    }

    func assignTag(uid: String) {
        assignedTagUID = uid
        UserDefaults.standard.set(uid, forKey: uidKey)
    }

    func clearTag() {
        assignedTagUID = nil
        UserDefaults.standard.removeObject(forKey: uidKey)
    }
}
