//  UnitManager.swift

import CoreData
import FirebaseFirestore
import FirebaseAuth

class UnitManager {
    private var firestoreUnitService = FirestoreUnitService()
    private var coreDataUnitService: CoreDataUnitService
    private var isAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }

    init(context: NSManagedObjectContext) {
        self.coreDataUnitService = CoreDataUnitService(context: context)
    }
    
    func fetchUnits(completion: @escaping ([String]) -> Void) {
        if isAuthenticated {
            firestoreUnitService.fetchUnits { units, _ in
                completion(units)
            }
        } else {
            let units = coreDataUnitService.units
            completion(units)
        }
    }

    func addUnit(_ name: String, completion: @escaping (Bool) -> Void) {
        if isAuthenticated {
            firestoreUnitService.addUnit(name) { success, _ in
                if success {
                    self.coreDataUnitService.addUnit(name)
                }
                completion(success)
            }
        } else {
            coreDataUnitService.addUnit(name)
            completion(true)
        }
    }

    func updateUnit(oldName: String, newName: String, completion: @escaping (Bool) -> Void) {
        if isAuthenticated {
            firestoreUnitService.updateUnit(oldName: oldName, newName: newName) { success, _ in
                if success {
                    self.coreDataUnitService.updateUnit(oldName: oldName, newName: newName) { success, _ in
                        completion(success)
                    }
                } else {
                    completion(false)
                }
            }
        } else {
            coreDataUnitService.updateUnit(oldName: oldName, newName: newName) { success, _ in
                completion(success)
            }
        }
    }

    func deleteUnit(_ name: String, completion: @escaping (Bool) -> Void) {
        if isAuthenticated {
            firestoreUnitService.deleteUnit(name) { success, _ in
                if success {
                    self.coreDataUnitService.deleteUnit(name) { success, _ in
                        completion(success)
                    }
                } else {
                    completion(false)
                }
            }
        } else {
            coreDataUnitService.deleteUnit(name) { success, _ in
                completion(success)
            }
        }
    }
}
