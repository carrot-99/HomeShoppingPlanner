//  Store.swift

import Foundation

struct Store: Identifiable, Equatable {
    let id: UUID
    var name: String
    var memos: [Memo]

    init(id: UUID = UUID(), name: String, memos: [Memo] = []) {
        self.id = id
        self.name = name
        self.memos = memos
    }
}

extension Store {
    init(entity: StoreEntity) {
        self.id = UUID(uuidString: entity.id ?? "") ?? UUID()
        self.name = entity.name ?? ""

        if let memosSet = entity.memos as? Set<CDMemo> {
            self.memos = memosSet.compactMap { Memo(entity: $0) }
        } else {
            self.memos = []
        }
    }
}
