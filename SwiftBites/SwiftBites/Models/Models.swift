//
//  Models.swift
//  SwiftBites
//
//  Created by Jonathan Sweeney on 6/8/26.
//

import Foundation
import SwiftData

@Model
final class Category {
    var name: String

    @Relationship(deleteRule: .nullify, inverse: \Recipe.category)
    var recipes: [Recipe] = []

    init(name: String) {
        self.name = name
    }
}

@Model
final class Recipe {
    var name: String
    var summary: String
    var serving: Int
    var time: Int
    var instructions: String
    var imageData: Data?
    var category: Category?

    @Relationship(deleteRule: .cascade)
    var ingredients: [RecipeIngredient] = []

    init(name: String, summary: String = "", serving: Int = 1, time: Int = 20, instructions: String = "", imageData: Data? = nil, category: Category? = nil) {
        self.name = name
        self.summary = summary
        self.serving = serving
        self.time = time
        self.instructions = instructions
        self.imageData = imageData
        self.category = category
    }
}

@Model
final class RecipeIngredient {
    var quantity: String
    
    @Relationship(deleteRule: .nullify)
    var ingredient: Ingredient?

    init(quantity: String, ingredient: Ingredient) {
        self.quantity = quantity
        self.ingredient = ingredient
    }
}

@Model
final class Ingredient {
    var name: String
    
    @Relationship(deleteRule: .nullify, inverse: \RecipeIngredient.ingredient)
    var recipeIngredients: [RecipeIngredient] = []

    init(name: String) {
        self.name = name
    }
}
