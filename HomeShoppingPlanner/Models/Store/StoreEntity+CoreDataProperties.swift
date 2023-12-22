//  StoreEntity+CoreDataProperties.swift

import Foundation
import CoreData


extension StoreEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreEntity> {
        return NSFetchRequest<StoreEntity>(entityName: "StoreEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: String?
    @NSManaged public var memos: NSSet?

}

// MARK: Generated accessors for memos
extension StoreEntity {

    @objc(addMemosObject:)
    @NSManaged public func addToMemos(_ value: MemoEntity)

    @objc(removeMemosObject:)
    @NSManaged public func removeFromMemos(_ value: MemoEntity)

    @objc(addMemos:)
    @NSManaged public func addToMemos(_ values: NSSet)

    @objc(removeMemos:)
    @NSManaged public func removeFromMemos(_ values: NSSet)

}
