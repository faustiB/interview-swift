import XCTest
@testable import SwiftRecipe

final class SwiftRecipeTests: XCTestCase {
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    let config = URLSessionConfiguration.default
    config.protocolClasses = [MockURLProtocol.self]
    URLProtocol.registerClass(MockURLProtocol.self)
  }
  
  override func tearDownWithError() throws {
    MockURLProtocol.requestHandler = nil
    URLProtocol.unregisterClass(MockURLProtocol.self)
    super.tearDown()
  }
  
  func testExample() throws {
  }
  
  func testInitialStateDefault() {
    let sut = RecipeListViewModel()
    
    XCTAssertEqual(sut.state.isLoading, false)
    XCTAssertEqual(sut.state.recipes.isEmpty, true)
    XCTAssertEqual(sut.state.statusMessage == nil, true)
  }
  
  func testSearchRecipesSuccess() async throws {
    MockURLProtocol.requestHandler = { request in
      let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
      let query = components?.queryItems?.first(where: { $0.name == "q" })?.value
      let json = """
            {"count":2,"recipes":[
              {"publisher":"Pub","title":"Pizza","source_url":"https://ex.com/pizza","recipe_id":"r1","image_url":"https://ex.com/p.jpg","social_rank":99.0,"publisher_url":"https://ex.com","ingredients":null},
              {"publisher":"Pub","title":"Pasta","source_url":"https://ex.com/pasta","recipe_id":"r2","image_url":"https://ex.com/pa.jpg","social_rank":98.0,"publisher_url":"https://ex.com","ingredients":null}
            ]}
            """.data(using: .utf8)!
      let url = URL(string: "https://forkify-api.herokuapp.com/api/search?q=\(query ?? "")")!
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
      return (response, json)
    }
    
    let sut = RecipeListViewModel()
    await MainActor.run {
      sut.searchRecipes(recipeSearchQuery: "pizza")
    }
    
    try await Task.sleep(nanoseconds: 200_000_000)
    
    XCTAssertEqual(sut.state.isLoading, false)
    XCTAssertEqual(sut.state.recipes.count, 2)
    XCTAssertEqual(sut.state.statusMessage == nil, true)
  }
  
  func testSearchRecipesEmptyResults() async throws {
    // This case is not happening because of some issue with the api, it never returns nor a 404 or an empty array, always is a bad request and I cannot override the bad request with this case.
    MockURLProtocol.requestHandler = { request in
      let json = """
            {"count":0,"recipes":[]}
            """.data(using: .utf8)!
      let url = URL(string: "https://forkify-api.herokuapp.com/api/search?q=pizza")!
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
      return (response, json)
    }
    
    let sut = RecipeListViewModel()
    await MainActor.run {
      sut.searchRecipes(recipeSearchQuery: "pizza")
    }
    
    try await Task.sleep(nanoseconds: 200_000_000)
    
    XCTAssertEqual(sut.state.isLoading, false)
    XCTAssertEqual(sut.state.recipes.count == 0, true)
    XCTAssertEqual(sut.state.statusMessage, "No results for pizza")
  }
}
