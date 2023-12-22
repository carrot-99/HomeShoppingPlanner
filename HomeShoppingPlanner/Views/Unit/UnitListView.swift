//  UnitListView.swift

import SwiftUI

struct UnitListView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var isEditing = false
    @State private var isNewUnit = false
    @State private var newName = ""
    @State private var editingUnit = ""

    var body: some View {
        List {
            ForEach(viewModel.units, id: \.self) { unit in
                Text(unit)
                    .onTapGesture {
                        self.editingUnit = unit
                        self.newName = unit
                        self.isEditing = true
                    }
            }
            .onDelete(perform: deleteUnit)
        }
        .navigationBarTitle("単位一覧")
        .navigationBarItems(trailing: Button(action: {
            self.isEditing = true
            self.isNewUnit = true
            self.newName = "" 
        }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $isEditing) {
            EditUnitView(unit: $editingUnit, newName: $newName, isNewUnit: $isNewUnit, saveAction: {
                if isNewUnit {
                    viewModel.addUnit(name: newName)
                } else {
                    viewModel.updateUnit(oldName: editingUnit, newName: newName)
                }
                self.isEditing = false
            })
        }
    }

    private func deleteUnit(at offsets: IndexSet) {
        for index in offsets {
            let unit = viewModel.units[index]
            viewModel.deleteUnit(name: unit)
        }
    }
}
