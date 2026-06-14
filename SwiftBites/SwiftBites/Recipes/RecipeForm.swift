import SwiftUI
import PhotosUI
import SwiftData

struct RecipeForm: View {
    enum Mode: Hashable {
        case add
        case edit(Recipe)
    }

    var mode: Mode

    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .add:
            title = "Add Recipe"
            _name = .init(initialValue: "")
            _summary = .init(initialValue: "")
            _serving = .init(initialValue: 1)
            _time = .init(initialValue: 5)
            _instructions = .init(initialValue: "")
            _ingredients = .init(initialValue: [])
        case .edit(let recipe):
            title = "Edit \(recipe.name)"
            _name = .init(initialValue: recipe.name)
            _summary = .init(initialValue: recipe.summary)
            _serving = .init(initialValue: recipe.serving)
            _time = .init(initialValue: recipe.time)
            _instructions = .init(initialValue: recipe.instructions)
            _ingredients = .init(initialValue: recipe.ingredients)
            _category = .init(initialValue: recipe.category)
            _imageData = .init(initialValue: recipe.imageData)

        }
    }

    private let title: String
    @State private var name: String
    @State private var summary: String
    @State private var serving: Int
    @State private var time: Int
    @State private var instructions: String
    @State private var category: Category?
    @State private var ingredients: [RecipeIngredient]
    @State private var imageItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var isIngredientsPickerPresented =  false
    @State private var error: Error?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var deletedIngredients: [RecipeIngredient] = []

    @Query private var categories: [Category]

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            Form {
                imageSection(width: geometry.size.width)
                nameSection
                summarySection
                categorySection
                servingAndTimeSection
                ingredientsSection
                instructionsSection
                deleteButton
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .alert(error: $error)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: save)
                    .disabled(name.isEmpty || instructions.isEmpty)
            }
        }
        .onChange(of: imageItem) { _, _ in
            Task {
                self.imageData = try? await imageItem?.loadTransferable(type: Data.self)
            }
        }
        .sheet(isPresented: $isIngredientsPickerPresented, content: ingredientPicker)
    }

    // MARK: - Views

    private func ingredientPicker() -> some View {
        IngredientsView { selectedIngredient in
            let recipeIngredient = RecipeIngredient(quantity: "", ingredient: selectedIngredient)
            ingredients.append(recipeIngredient)
        }
    }

    @ViewBuilder
    private func imageSection(width: CGFloat) -> some View {
        Section {
            imagePicker(width: width)
            removeImage
        }
    }

    @ViewBuilder
    private func imagePicker(width: CGFloat) -> some View {
        PhotosPicker(selection: $imageItem, matching: .images) {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width)
                    .clipped()
                    .listRowInsets(EdgeInsets())
                    .frame(maxWidth: .infinity, minHeight: 200, idealHeight: 200, maxHeight: 200, alignment: .center)
            } else {
                Label("Select Image", systemImage: "photo")
            }
        }
    }

    @ViewBuilder
    private var removeImage: some View {
        if imageData != nil {
            Button(
                role: .destructive,
                action: {
                    imageData = nil
                },
                label: {
                    Text("Remove Image")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            )
        }
    }

    @ViewBuilder
    private var nameSection: some View {
        Section("Name") {
            TextField("Margherita Pizza", text: $name)
        }
    }

    @ViewBuilder
    private var summarySection: some View {
        Section("Summary") {
            TextField(
                "Delicious blend of fresh basil, mozzarella, and tomato on a crispy crust.",
                text: $summary,
                axis: .vertical
            )
            .lineLimit(3...5)
        }
    }

    @ViewBuilder
    private var categorySection: some View {
        Section {
            Picker("Category", selection: $category) {
                Text("None").tag(nil as Category?)
                ForEach(categories) { cat in
                    Text(cat.name).tag(cat as Category?)
                }
            }
        }
    }

    @ViewBuilder
    private var servingAndTimeSection: some View {
        Section {
            Stepper("Servings: \(serving)p", value: $serving, in: 1...100)
            Stepper("Time: \(time)m", value: $time, in: 5...300, step: 5)
        }
        .monospacedDigit()
    }

    @ViewBuilder
    private var ingredientsSection: some View {
        Section("Ingredients") {
            if ingredients.isEmpty {
                ContentUnavailableView(
                    label: {
                        Label("No Ingredients", systemImage: "list.clipboard")
                    },
                    description: {
                        Text("Recipe ingredients will appear here.")
                    },
                    actions: {
                        Button("Add Ingredient") {
                            isIngredientsPickerPresented = true
                        }
                    }
                )
            } else {
                ForEach(ingredients) { ingredient in
                    if let ing = ingredient.ingredient {
                        HStack(alignment: .center) {
                            Text(ing.name)
                                .bold()
                                .layoutPriority(2)
                            Spacer()
                            TextField("Quantity", text: .init(
                                get: {
                                    ingredient.quantity
                                },
                                set: { quantity in
                                    if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
                                        ingredients[index].quantity = quantity
                                    }
                                }
                            ))
                            .layoutPriority(1)
                        }
                    }
                }
                .onDelete(perform: deleteIngredients)

                Button("Add Ingredient") {
                    isIngredientsPickerPresented = true
                }
            }
        }
    }

    @ViewBuilder
    private var instructionsSection: some View {
        Section("Instructions") {
            TextField(
        """
        1. Preheat the oven to 475°F (245°C).
        2. Roll out the dough on a floured surface.
        3. ...
        """,
        text: $instructions,
        axis: .vertical
            )
            .lineLimit(8...12)
        }
    }

    @ViewBuilder
    private var deleteButton: some View {
        if case .edit(let recipe) = mode {
            Button(
                role: .destructive,
                action: {
                    delete(recipe: recipe)
                },
                label: {
                    Text("Delete Recipe")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            )
        }
    }

    // MARK: - Data

    func delete(recipe: Recipe) {
        context.delete(recipe)
        dismiss()
    }

    func deleteIngredients(offsets: IndexSet) {
        withAnimation {
            let removed = offsets.map { ingredients[$0] }
            deletedIngredients.append(contentsOf: removed)
            ingredients.remove(atOffsets: offsets)
        }
    }

    func save() {
        for ingredient in deletedIngredients {
            context.delete(ingredient)
        }
        switch mode {
        case .add:
            let recipe = Recipe(
                name: name,
                summary: summary,
                serving: serving,
                time: time,
                instructions: instructions,
                imageData: imageData,
                category: category
            )
            recipe.ingredients = ingredients
            context.insert(recipe)
        case .edit(let recipe):
            recipe.name = name
            recipe.summary = summary
            recipe.serving = serving
            recipe.time = time
            recipe.instructions = instructions
            recipe.imageData = imageData
            recipe.category = category
            recipe.ingredients = ingredients
        }
        dismiss()
    }
}
