//
//  UserListItem.swift
//  RandomUserApp
//
//  Created by JooYoung Kim on 1/12/26.
//

import Foundation

struct UserListItem: Hashable, Sendable {
    let uuid: String
    let name: String
    let subtitle: String
    let thumbnailURL: URL?

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }

    static func == (lhs: UserListItem, rhs: UserListItem) -> Bool {
        lhs.uuid == rhs.uuid
    }
}
