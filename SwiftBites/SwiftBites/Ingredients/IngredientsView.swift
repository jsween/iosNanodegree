import SwiftUI
import SwiftData

struct IngredientsView: View {
    typealias Selection = (Ingredient) -> Void

    let selection: Selection?

    init(selection: Selection? = nil) {
        self.selection = selection
    }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var body: some View {
        NavigationStack {
            IngredientListView(query: query, selection: selection)
                .navigationTitle("Ingredients")
                .toolbar {
                    NavigationLink(value: IngredientForm.Mode.add) {
                        Label("Add", systemImage: "plus")
                    }
                }
                .navigationDestination(for: IngredientForm.Mode.self) { mode in
                    IngredientForm(mode: mode)
                }
                .searchable(text: $query)
        }
    }
}

private struct IngredientListView: View {
    typealias Selection = (Ingredient) -> Void

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var ingredients: [Ingredient]

    let selection: Selection?

    init(query: String, selection: Selection? = nil) {
        self.selection = selection
        let predicate = #Predicate<Ingredient> { ingredient in
            query.isEmpty ? true : ingredient.name.contains(query)
        }
        _ingredients = Query(filter: predicate, animation: .default)
    }

    var body: some View {
        if ingredients.isEmpty {
            ContentUnavailableView(
                label: {
                    Label("No Ingredients", systemImage: "list.clipboard")
                },
                description: {
                    Text("Ingredients you add will appear here.")
                },
                actions: {
                    NavigationLink("Add Ingredient", value: IngredientForm.Mode.add)
                        .buttonBorderShape(.roundedRectangle)
                        .buttonStyle(.borderedProminent)
                }
            )
        } else {
            List {
                ForEach(ingredients) { ingredient in
                    row(for: ingredient)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                context.delete(ingredient)
                            }
                        }
                }
            }
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private func row(for ingredient: Ingredient) -> some View {
        if let selection {
            Button(
                action: {
                    selection(ingredient)
                    dismiss()
                },
                label: { title(for: ingredient) }
            )
        } else {
            NavigationLink(value: IngredientForm.Mode.edit(ingredient)) {
                title(for: ingredient)
            }
        }
    }

    private func title(for ingredient: Ingredient) -> some View {
        Text(ingredient.name)
            .font(.title3)
    }
}
