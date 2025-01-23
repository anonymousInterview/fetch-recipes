import Testing
import Foundation
@testable import Recipes

@Suite struct RecipeTests {
    @Test func cousineDecodesCorrectly() async throws {
        let decoder = JSONDecoder()
        let rawData = """
        ["American", "British", "Mexican"]
        """.data(using: .utf8)!
        let cousines = try decoder.decode([Recipe.Cousine].self, from: rawData)
        
        #expect( cousines.count == 3 )
        #expect( cousines[0] == .american )
        #expect( cousines[1] == .british )
        #expect( cousines[2] == .other("mexican") )
    }
}
