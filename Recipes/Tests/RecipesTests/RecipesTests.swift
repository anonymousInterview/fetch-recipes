import Testing
import Foundation
@testable import Recipes

@Suite struct RecipeTests {
    @Test func cuisineDecodesCorrectly() throws {
        let decoder = JSONDecoder()
        let rawData = """
        ["American", "British", "Mexican"]
        """.data(using: .utf8)!
        let cuisines = try decoder.decode([Recipe.Cuisine].self, from: rawData)
        
        #expect( cuisines.count == 3 )
        #expect( cuisines[0] == .american )
        #expect( cuisines[1] == .british )
        #expect( cuisines[2] == .other("mexican") )
    }
}
