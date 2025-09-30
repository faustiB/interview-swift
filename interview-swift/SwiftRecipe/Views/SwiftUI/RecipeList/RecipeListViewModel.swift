
import Foundation
import SwiftUI
import Combine

final class RecipeListViewModel: ObservableObject {
  
  private let recipeService: RecipeService
  // To keep subscriptions from combine alive, until the user exists.
  private var cancellables = Set<AnyCancellable>()
  
  // TODO: - #2:  In RecipeListViewModel: publish search results to the RecipeListView using the
  //  RecipeService. The screen should show a blank page when the query is empty, a loading
  //  indicator while the page is loading, and a list of results when the repository returns data.
  //  See the screenshots in README.md.
  
  @Published var state: State = .default
  @Published var recipeSearchQuery: String = ""
  
  init(recipeService: RecipeService = RecipeService()) {
    self.recipeService = recipeService
    
    // Debounced search
    $recipeSearchQuery
      .debounce(for: 0.3, scheduler: DispatchQueue.main)
      .removeDuplicates()
      .sink { [weak self] searchValue in
        self?.searchRecipes(recipeSearchQuery: searchValue)
      }
      .store(in: &cancellables)
      
  }
  
  struct State {
    let isLoading: Bool
    let statusMessage: String?
    let recipes: [Recipe]
    
    init(
      isLoading: Bool = false,
      statusMessage: String? = nil,
      recipes: [Recipe]? = nil
    ) {
      self.isLoading = isLoading
      self.statusMessage = statusMessage
      self.recipes = recipes ?? []
    }
    
    static let `default` = State()
    static let loading = State(isLoading: true)
  }
  
  func searchRecipes(recipeSearchQuery: String){
    print(recipeSearchQuery)
  }
}
