import XCTest
@testable import SwiftRecipe

final class RecipeDetailViewModelTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    URLProtocol.registerClass(MockURLProtocol.self)
  }
  
  override func tearDown() {
    MockURLProtocol.requestHandler = nil
    URLProtocol.unregisterClass(MockURLProtocol.self)
    super.tearDown()
  }
  
  func testInitInitFetchSuccess() async throws {
    MockURLProtocol.requestHandler = { request in
      let json = """
            {"recipe":{
              "publisher":"Pub","title":"Pizza","source_url":"https://ex.com/pizza","recipe_id":"r1","image_url":"https://ex.com/p.jpg","social_rank":99.0,"publisher_url":"https://ex.com","ingredients":["Flour","Water"]
            }}
            """.data(using: .utf8)!
      let url = URL(string: "https://forkify-api.herokuapp.com/api/get?rId=r1")!
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
      return (response, json)
    }
    
    let sut = await MainActor.run {
      RecipeDetailViewModel(recipeId: "r1")
    }
    
    try await Task.sleep(nanoseconds: 200_000_000)
    
    await MainActor.run {
      XCTAssertEqual(sut.isLoading, false)
      XCTAssertEqual(sut.recipeDetails?.id, "r1")
      XCTAssertEqual(sut.recipeDetails?.title, "Pizza")
      XCTAssertEqual(sut.recipeDetails?.socialRank, 99.0)
    }
  }
  
  func testFetchRecipeDetailsStopLoadingOnError() async throws {
    MockURLProtocol.requestHandler = { request in
      let url = URL(string: "https://forkify-api.herokuapp.com/api/get?rId=r1")!
      let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
      return (response, Data())
    }
    
    let sut = await MainActor.run {
      RecipeDetailViewModel(recipeId: "r1")
    }
    
    try await Task.sleep(nanoseconds: 200_000_000)
    
    await MainActor.run {
      XCTAssertEqual(sut.isLoading, false)
      XCTAssertEqual(sut.recipeDetails == nil, true)
      XCTAssertEqual(sut.errorMessage, "Something went wrong. Tap to retry fetch of the recipe details.")
    }
  }
}


