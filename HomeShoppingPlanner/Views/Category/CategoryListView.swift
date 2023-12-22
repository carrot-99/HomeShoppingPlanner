//  CategoryListView.swift

import SwiftUI

struct CategoryListView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var isEditing = false
    @State private var isNewCategory = false
    @State private var newName = ""
    @State private var editingCategory = ""

    var body: some View {
        List {
            ForEach(viewModel.categories, id: \.self) { category in
                Text(category)
                    .onTapGesture {
                        self.editingCategory = category
                        self.newName = category
                        self.isEditing = true
                    }
            }
            .onDelete(perform: deleteCategory)
        }
        .navigationBarTitle("カテゴリ一覧")
        .navigationBarItems(trailing: Button(action: {
            self.isEditing = true
            self.isNewCategory = true
            self.newName = ""
        }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $isEditing) {
            EditCategoryView(category: $editingCategory, newName: $newName, isNewCategory: $isNewCategory, saveAction: {
                if isNewCategory {
                    viewModel.addCategory(name: newName)
                } else {
                    viewModel.updateCategory(oldName: editingCategory, newName: newName)
                }
                self.isEditing = false
            })
        }
    }

    private func deleteCategory(at offsets: IndexSet) {
        for index in offsets {
            let category = viewModel.categories[index]
            viewModel.deleteCategory(name: category)
        }
    }
}
