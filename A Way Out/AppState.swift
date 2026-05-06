//
//  AppState.swift
//  A Way Out
//

import Foundation
import Combine
import FamilyControls
#if os(iOS)
import ManagedSettings
#endif

final class AppState: ObservableObject {
    static let shared = AppState()

    @Published private(set) var assignedTagUID: String?
    @Published private(set) var appGroups: [AppGroup] = []
    @Published private(set) var blockedGroupIDs: Set<UUID> = []

    private let uidKey = "assignedTagUID"
    private let groupsKey = "appGroups"
    private let blockedGroupsKey = "blockedGroupIDs"
    #if os(iOS)
    private let store = ManagedSettingsStore()
    #endif

    private init() {
        assignedTagUID = UserDefaults.standard.string(forKey: uidKey)
        loadGroups()
        loadBlockedGroups()
        applyShields()
    }

    func assignTag(uid: String) {
        assignedTagUID = uid
        UserDefaults.standard.set(uid, forKey: uidKey)
    }

    func clearTag() {
        assignedTagUID = nil
        UserDefaults.standard.removeObject(forKey: uidKey)
    }

    func addGroup(_ group: AppGroup) {
        appGroups.append(group)
        saveGroups()
    }

    func updateGroup(_ group: AppGroup) {
        guard let index = appGroups.firstIndex(where: { $0.id == group.id }) else { return }
        appGroups[index] = group
        saveGroups()
    }

    func deleteGroups(at offsets: IndexSet) {
        for index in offsets.sorted().reversed() {
            appGroups.remove(at: index)
        }
        saveGroups()
    }

    func deleteGroup(id: UUID) {
        appGroups.removeAll { $0.id == id }
        blockedGroupIDs.remove(id)
        saveGroups()
        saveBlockedGroups()
        applyShields()
    }

    func activateBlocking(for groupID: UUID) {
        blockedGroupIDs.insert(groupID)
        saveBlockedGroups()
        applyShields()
    }

    func deactivateBlocking(for groupID: UUID) {
        blockedGroupIDs.remove(groupID)
        saveBlockedGroups()
        applyShields()
    }

    private func applyShields() {
        #if os(iOS)
        let blocked = appGroups.filter { blockedGroupIDs.contains($0.id) }
        let appTokens = blocked.reduce(into: Set<ApplicationToken>()) { $0.formUnion($1.selection.applicationTokens) }
        let categoryTokens = blocked.reduce(into: Set<ActivityCategoryToken>()) { $0.formUnion($1.selection.categoryTokens) }

        store.shield.applications = appTokens.isEmpty ? nil : appTokens
        store.shield.applicationCategories = categoryTokens.isEmpty ? nil : .specific(categoryTokens)
        #endif
    }

    private func saveGroups() {
        if let data = try? JSONEncoder().encode(appGroups) {
            UserDefaults.standard.set(data, forKey: groupsKey)
        }
    }

    private func loadGroups() {
        guard let data = UserDefaults.standard.data(forKey: groupsKey),
              let groups = try? JSONDecoder().decode([AppGroup].self, from: data) else { return }
        appGroups = groups
    }

    private func saveBlockedGroups() {
        let strings = blockedGroupIDs.map { $0.uuidString }
        UserDefaults.standard.set(strings, forKey: blockedGroupsKey)
    }

    private func loadBlockedGroups() {
        guard let strings = UserDefaults.standard.stringArray(forKey: blockedGroupsKey) else { return }
        blockedGroupIDs = Set(strings.compactMap { UUID(uuidString: $0) })
    }
}
