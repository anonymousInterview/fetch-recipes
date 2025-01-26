//
//  FetchRecipesTests.swift
//  FetchRecipesTests
//
//

@testable import FetchRecipes
@testable import Networking
@testable import Recipes
import Testing

@Suite struct FetchRecipesTests {
    /// This is an additional layer meant as a safeguard to put a layer of friction
    /// when updating root dependencies.
    @Test func checkBaselineDependencies() throws {
        let view = FetchRecipesApp()
        #expect(view.client is DefaultHTTPClient)
        #expect(view.imageLoader is DefaultImageLoader)
    }
}
