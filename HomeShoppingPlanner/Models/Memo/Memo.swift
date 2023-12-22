//  Memo.swift

import Foundation
import FirebaseFirestore

struct Memo: Identifiable, Equatable {
    var storeId: UUID
    let id: UUID
    var name: String
    var quantity: Int
    var unit: String
    var needBy: Date
    var priority: String
    var isPurchased: Bool
    var category: String
    var note: String?
    var imageData: Data?
    var imageURL: String?
    
    static let defaultCategories = ["食料品", "日用品", "衣料品", "薬剤品", "嗜好品", "その他"]
    static let defaultUnits = ["個", "本", "袋", "g"]

    init(
        storeId: UUID = UUID(),
        id: UUID = UUID(),
        name: String,
        quantity: Int,
        unit: String,
        needBy: Date,
        priority: String,
        isPurchased: Bool = false,
        category: String = defaultCategories[0],
        note: String? = nil,
        imageData: Data? = nil,
        imageURL: String? = ""
    ) {
        self.storeId = storeId
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.needBy = needBy
        self.priority = priority
        self.isPurchased = isPurchased
        self.category = category
        self.note = note
        self.imageData = imageData
        self.imageURL = imageURL
    }
}

extension Memo {
    // coreDataのデータ形式に変換するためのイニシャライザ
    init(entity: CDMemo) {
        self.storeId = UUID(uuidString: entity.storeId ?? "") ?? UUID()
        self.id = UUID(uuidString: entity.id ?? "") ?? UUID()
        self.name = entity.name ?? ""
        self.quantity = Int(entity.quantity)
        self.unit = entity.unit ?? ""
        self.needBy = entity.needBy ?? Date()
        self.priority = entity.priority ?? ""
        self.isPurchased = entity.isPurchased
        self.category = entity.category ?? Memo.defaultCategories[0]
        self.note = entity.note
        self.imageData = entity.imageData
        self.imageURL = entity.imageURL
    }
}

extension Memo {
    // Firestoreのデータ形式に変換するためのイニシャライザ
    init?(data: [String: Any]) {
        guard let id = UUID(uuidString: data["id"] as? String ?? ""),
              let storeId = UUID(uuidString: data["storeId"] as? String ?? ""),
              let name = data["name"] as? String,
              let quantity = data["quantity"] as? Int,
              let unit = data["unit"] as? String,
              let priority = data["priority"] as? String,
              let isPurchased = data["isPurchased"] as? Bool,
              let category = data["category"] as? String,
              let timestamp = data["needBy"] as? Timestamp else { return nil }
        

        let needBy = timestamp.dateValue()
        let note = data["note"] as? String
        let imageData = data["imageData"] as? Data
        let imageURL = data["imageURL"] as? String
        self.init(storeId: storeId, id: id, name: name, quantity: quantity, unit: unit, needBy: needBy, priority: priority, isPurchased: isPurchased, category: category, note: note, imageData: nil, imageURL: imageURL)
    }

    // Firestoreに保存するための辞書形式に変換するメソッド
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "storeId": storeId.uuidString,
            "name": name,
            "quantity": quantity,
            "unit": unit,
            "needBy": needBy,
            "priority": priority,
            "isPurchased": isPurchased,
            "category": category
        ]

        if let note = note {
            dict["note"] = note
        }

        if let imageData = imageData {
            dict["imageData"] = imageData
        }
        
        if let imageURL = imageURL {
            dict["imageURL"] = imageURL
        }

        return dict
    }
}
