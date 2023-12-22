//  CategoryManager.swift

import CoreData
import FirebaseFirestore
import FirebaseAuth

class CategoryManager {
    private var firestoreCategoryService = FirestoreCategoryService()
    private var coreDataCategoryService: CoreDataCategoryService
    private var isAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }

    init(context: NSManagedObjectContext) {
        self.coreDataCategoryService = CoreDataCategoryService(context: context)
    }
    
    func fetchCategories(completion: @escaping ([String]) -> Void) {
        if isAuthenticated {
            firestoreCategoryService.fetchCategories { categories, _ in
                completion(categories)
            }
        } else {
            let categories = coreDataCategoryService.categories
            completion(categories)
        }
    }

    func addCategory(_ name: String, completion: @escaping (Bool) -> Void) {
        if isAuthenticated {
            firestoreCategoryService.addCategory(name) { success, _ in
                if success {
                    self.coreDataCategoryService.addCategory(name) { success, _ in
                        completion(success)
                    }
                } else {
                    completion(false)
                }
            }
        } else {
            coreDataCategoryService.addCategory(name) { success, _ in
                completion(success)
            }
        }
    }

    func updateCategory(oldName: String, newName: String, completion: @escaping (Bool) -> Void) {
        if isAuthenticated {
            firestoreCategoryService.updateCategory(oldName: oldName, newName: newName) { success, _ in
                if success {
                    self.coreDataCategoryService.updateCategory(oldName: oldName, newName: newName) { success, _ in
                        completion(success)
                    }
                } else {
                    completion(false)
                }
            }
        } else {
            coreDataCategoryService.updateCategory(oldName: oldName, newName: newName) { success, _ in
                completion(success)
            }
        }
    }

    func deleteCategory(_ name: String, completion: @escaping (Bool) -> Void) {
        if isAuthenticated {
            firestoreCategoryService.deleteCategory(name) { success, _ in
                if success {
                    self.coreDataCategoryService.deleteCategory(name) { success, _ in
                        completion(success)
                    }
                } else {
                    completion(success)
                }
            }
        } else {
            coreDataCategoryService.deleteCategory(name) { success, _ in
                completion(success)
            }
        }
    }
}
