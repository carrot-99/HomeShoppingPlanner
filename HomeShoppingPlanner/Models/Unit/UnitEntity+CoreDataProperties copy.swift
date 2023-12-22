//  UnitEntity+CoreDataProperties.swift

import Foundation
import CoreData


extension UnitEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UnitEntity> {
        return NSFetchRequest<UnitEntity>(entityName: "UnitEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?

}
