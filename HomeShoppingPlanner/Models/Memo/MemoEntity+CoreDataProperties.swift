//  MemoEntity+CoreDataProperties.swift

import Foundation
import CoreData


extension MemoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemoEntity> {
        return NSFetchRequest<MemoEntity>(entityName: "MemoEntity")
    }

    @NSManaged public var storeId: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var quantity: Int64
    @NSManaged public var unit: String?
    @NSManaged public var needBy: Date?
    @NSManaged public var priority: String?
    @NSManaged public var isPurchased: Bool
    @NSManaged public var category: String?
    @NSManaged public var note: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var imageURL: String?
    @NSManaged public var store: StoreEntity?

}
