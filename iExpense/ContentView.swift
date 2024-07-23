//
//  ContentView.swift
//  iExpense
//
//  Created by Jesutofunmi Adewole on 20/02/2024.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable, Equatable, Hashable {
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
                UserDefaults.standard.set(encoded, forKey: "Items")
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
    
    var personalItems: [ExpenseItem] {
        expenses.items.filter { $0.type == "Personal" }
    }
    
    var businessItems: [ExpenseItem] {
        expenses.items.filter { $0.type == "Business" }
    }
    
    var body: some View {
        
        NavigationStack {
            List {
                Section("Business Expenses") {
                    ForEach(businessItems) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                            }
                            Spacer()
                            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                .foregroundStyle( item.amount < 10000 ? .green: item.amount > 100000 ? .red : .blue)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        removeBusinessItems(at: indexSet)
                    })
                }
                
                Section("Personal Expenses") {
                    ForEach(personalItems) { item in
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                            }
                            Spacer()
                            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                .foregroundStyle( item.amount < 10000 ? .green: item.amount > 100000 ? .red : .blue)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        removePersonalItems(at: indexSet)
                    })
                }
            }
            .navigationTitle("iExpense")
            .toolbar {
                NavigationLink {
                    AddView(expenses: expenses)
                } label: {
                    Label("Add Expense", systemImage: "plus")
                }
            }
        }
    }
    
    func removeBusinessItems(at offsets: IndexSet) {
        offsets.map { businessItems[$0] }.forEach { item in
            if let index = expenses.items.firstIndex(of: item) {
                expenses.items.remove(at: index)
            }
        }
    }
    
    func removePersonalItems(at offsets: IndexSet) {
        offsets.map { personalItems[$0] }.forEach { item in
            if let index = expenses.items.firstIndex(of: item) {
                expenses.items.remove(at: index)
            }
        }
    }
}

#Preview {
    ContentView()
}

