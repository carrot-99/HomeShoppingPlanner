//  CoreDataCategoryService.swift

import CoreData

class CoreDataCategoryService {
    private var context: NSManagedObjectContext
    @Published var categories = Memo.defaultCategories

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchCategories()
    }
    
    private func fetchCategories() {
        let fetchRequest: NSFetchRequest<CDCategory> = CDCategory.fetchRequest()
        do {
            let categoriesEntities = try context.fetch(fetchRequest)
            let fetchedCategories = categoriesEntities.compactMap { $0.name ?? "" }
            self.categories = Array(Set(Memo.defaultCategories + fetchedCategories))
        } catch {
            print("Error fetching categories: \(error)")
        }
    }

    func addCategory(_ name: String, completion: @escaping (Bool, String) -> Void) {
        let newCategory = CDCategory(context: context)
        newCategory.id = UUID()
        newCategory.name = name

        do {
            try context.save()
            fetchCategories()
            completion(true, "")
        } catch {
            completion(false, "カテゴリの保存に失敗しました。")
        }
    }
    
    func updateCategory(oldName: String, newName: String, completion: @escaping (Bool, String) -> Void) {
        let fetchRequest: NSFetchRequest<CDCategory> = CDCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", oldName)

        if let categoriesToUpdate = try? context.fetch(fetchRequest), let categoryToUpdate = categoriesToUpdate.first {
            categoryToUpdate.name = newName
            do {
                try context.save()
                fetchCategories()
                completion(true, "")
            } catch {
                completion(false, "カテゴリの更新に失敗しました。")
            }
        } else {
            completion(false, "更新対象のカテゴリが見つかりません。")
        }
    }
    
    func deleteCategory(_ category: String, completion: @escaping (Bool, String) -> Void) {
        let memoFetchRequest: NSFetchRequest<CDMemo> = CDMemo.fetchRequest()
        memoFetchRequest.predicate = NSPredicate(format: "category == %@", category)

        if let memosWithCategory = try? context.fetch(memoFetchRequest), !memosWithCategory.isEmpty {
            completion(false, "このカテゴリは使用中のため、削除できません。： '\(category)'")
            return
        }

        let fetchRequest: NSFetchRequest<CDCategory> = CDCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", category)

        if let categoriesToDelete = try? context.fetch(fetchRequest) {
            for category in categoriesToDelete {
                context.delete(category)
            }

            do {
                try context.save()
                fetchCategories()
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }
}
