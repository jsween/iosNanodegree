import SwiftUI
import SwiftData

struct RecipesView: View {
    @State private var query = ""
    @State private var sortOrder = SortDescriptor(\Recipe.name)

    var body: some View {
        NavigationStack {
            RecipeListView(query: query, sortOrder: sortOrder)
                .navigationTitle("Recipes")
                .toolbar {
                    sortOptions
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: RecipeForm.Mode.add) {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                .navigationDestination(for: RecipeForm.Mode.self) { mode in
                    RecipeForm(mode: mode)
                }
                .searchable(text: $query)
        }
    }

    @ToolbarContentBuilder
    var sortOptions: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                Picker("Sort", selection: $sortOrder) {
                    Text("Name")
                        .tag(SortDescriptor(\Recipe.name))
                    Text("Serving (low to high)")
                        .tag(SortDescriptor(\Recipe.serving, order: .forward))
                    Text("Serving (high to low)")
                        .tag(SortDescriptor(\Recipe.serving, order: .reverse))
                    Text("Time (short to long)")
                        .tag(SortDescriptor(\Recipe.time, order: .forward))
                    Text("Time (long to short)")
                        .tag(SortDescriptor(\Recipe.time, order: .reverse))
                }
            }
            .pickerStyle(.inline)
        }
    }
}

private struct RecipeListView: View {
    @Query private var recipes: [Recipe]

    init(query: String, sortOrder: SortDescriptor<Recipe>) {
        let predicate = #Predicate<Recipe> { recipe in
            query.isEmpty ? true : recipe.name.contains(query) || recipe.summary.localizedStandardContains(query)
        }
        _recipes = Query(filter: predicate, sort: [sortOrder], animation: .default)
    }

    var body: some View {
        if recipes.isEmpty {
            ContentUnavailableView(
                label: {
                    Label("No Recipes", systemImage: "list.clipboard")
                },
                description: {
                    Text("Recipes you add will appear here.")
                },
                actions: {
                    NavigationLink("Add Recipe", value: RecipeForm.Mode.add)
                        .buttonBorderShape(.roundedRectangle)
                        .buttonStyle(.borderedProminent)
                }
            )
        } else {
            ScrollView(.vertical) {
                LazyVStack(spacing: 10) {
                    ForEach(recipes, content: RecipeCell.init)
                }
            }
        }
    }
}
