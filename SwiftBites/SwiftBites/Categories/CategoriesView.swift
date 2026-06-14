import SwiftUI
import SwiftData

struct CategoriesView: View {
    @State private var query = ""

    var body: some View {
        NavigationStack {
            CategoryListView(query: query)
                .navigationTitle("Categories")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: CategoryForm.Mode.add) {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                .navigationDestination(for: CategoryForm.Mode.self) { mode in
                    CategoryForm(mode: mode)
                }
                .navigationDestination(for: RecipeForm.Mode.self) { mode in
                    RecipeForm(mode: mode)
                }
                .searchable(text: $query)
        }
    }
}

private struct CategoryListView: View {
    @Query private var categories: [Category]

    init(query: String) {
        let predicate = #Predicate<Category> { category in
            query.isEmpty ? true : category.name.localizedStandardContains(query)
        }
        _categories = Query(filter: predicate, animation: .default)
    }

    var body: some View {
        if categories.isEmpty {
            ContentUnavailableView(
                label: {
                    Label("No Categories", systemImage: "list.clipboard")
                },
                description: {
                    Text("Categories you add will appear here.")
                },
                actions: {
                    NavigationLink("Add Category", value: CategoryForm.Mode.add)
                        .buttonBorderShape(.roundedRectangle)
                        .buttonStyle(.borderedProminent)
                }
            )
        } else {
            ScrollView(.vertical) {
                LazyVStack(spacing: 10) {
                    ForEach(categories, content: CategorySection.init)
                }
            }
        }
    }

}
