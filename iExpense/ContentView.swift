//
//  ContentView.swift
//  iExpense
//
//  Created by noor on 2/20/25.
//

import SwiftUI

struct ExpenseItem : Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.setValue(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    @State private var showingExpenseView = false
    var body: some View {
        NavigationStack {
            List {
                Section("Business") {
                    ForEach(expenses.items.filter {$0.type == "Business"}) { item in
                        ExpenseRow(item: item)
                    }
                    .onDelete(perform: { offsets in
                        removeItems(at: offsets, type: "Business")
                    })
                }
                
                Section("Personal") {
                    ForEach(expenses.items.filter {$0.type == "Personal"}) { item in
                        ExpenseRow(item: item)
                    }
                    .onDelete(perform: { offsets in
                        removeItems(at: offsets, type: "Personal")
                    })
                }
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("Add Expense", systemImage: "plus") {
                    showingExpenseView = true
                }
                EditButton()
            }
            .sheet(isPresented: $showingExpenseView) {
                AddView(expenses: expenses)
            }
        }
    }
    
    func removeItems(at offsets : IndexSet, type: String) {
        let filteredItems = expenses.items.filter { $0.type == type }
        let indicesToDelete = offsets.map { filteredItems[$0].id }
        expenses.items.removeAll { indicesToDelete.contains($0.id) }
    }
}

//reusable view
struct ExpenseRow : View {
    let item : ExpenseItem
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(item.name)")
                    .font(.headline)
                Text("\(item.type)")
                    .foregroundStyle(.gray)
            }
            Spacer()
            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .foregroundStyle(item.amount > 100 ? .red : (item.amount > 25 ? .blue : .green))
                .fontWeight(item.amount > 100 ? .bold : .regular)
        }
    }
}
#Preview {
    ContentView()
}
