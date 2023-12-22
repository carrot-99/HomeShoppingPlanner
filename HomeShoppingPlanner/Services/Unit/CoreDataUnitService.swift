//  CoreDataUnitService.swift

import CoreData

class CoreDataUnitService {
    private var context: NSManagedObjectContext
    @Published var units = Memo.defaultUnits
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchUnits()
    }
    
    private func fetchUnits() {
        let fetchRequest: NSFetchRequest<CDUnit> = CDUnit.fetchRequest()
        do {
            let unitsEntities = try context.fetch(fetchRequest)
            let fetchedUnits = unitsEntities.compactMap { $0.name ?? "" }
            self.units = Array(Set(Memo.defaultUnits + fetchedUnits))
        } catch {
            print("Error fetching units: \(error)")
        }
    }

    func addUnit(_ name: String) {
        let newUnit = CDUnit(context: context)
        newUnit.id = UUID()
        newUnit.name = name

        do {
            try context.save()
            fetchUnits()
        } catch {
            print("Error saving unit: \(error)")
        }
    }
    
    func updateUnit(oldName: String, newName: String, completion: @escaping (Bool, String) -> Void) {
        let fetchRequest: NSFetchRequest<CDUnit> = CDUnit.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", oldName)

        if let unitsToUpdate = try? context.fetch(fetchRequest), let unitToUpdate = unitsToUpdate.first {
            unitToUpdate.name = newName
            do {
                try context.save()
                fetchUnits()
                completion(true, "")
            } catch {
                completion(false, "単位の更新に失敗しました。")
            }
        } else {
            completion(false, "更新対象の単位が見つかりません。")
        }
    }
    
    func deleteUnit(_ unit: String, completion: @escaping (Bool, String) -> Void) {
        let memoFetchRequest: NSFetchRequest<CDMemo> = CDMemo.fetchRequest()
        memoFetchRequest.predicate = NSPredicate(format: "unit == %@", unit)

        if let memosWithUnit = try? context.fetch(memoFetchRequest), !memosWithUnit.isEmpty {
            completion(false, "この単位は使用中のため、削除できません。： '\(unit)'")
            return
        }

        let fetchRequest: NSFetchRequest<CDUnit> = CDUnit.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", unit)

        if let unitsToDelete = try? context.fetch(fetchRequest) {
            for unit in unitsToDelete {
                context.delete(unit)
            }

            do {
                try context.save()
                fetchUnits()
            } catch {
                print("Error deleting unit: \(error)")
            }
        }
    }
}
