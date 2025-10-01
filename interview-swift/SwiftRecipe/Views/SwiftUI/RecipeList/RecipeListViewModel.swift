
import Foundation
import SwiftUI
import Combine

final class RecipeListViewModel: ObservableObject {
  
  private let recipeService: RecipeService
  // To keep subscriptions from combine alive, until the user exists.
  private var cancellables = Set<AnyCancellable>()
  // Task to perform the search async.
  private var searchTask: Task<Void, Error>?

  @Published var state: State = .default
  @Published var recipeSearchQuery: String = ""
  
  init(recipeService: RecipeService = RecipeService()) {
    self.recipeService = recipeService
    
    // Debounced search
    $recipeSearchQuery
      .debounce(for: .milliseconds(300) , scheduler: DispatchQueue.main)
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
    let trimmedSearch = recipeSearchQuery.trimmingCharacters(in: .whitespaces)
    
    state = .loading

    //cancel previous ones
    searchTask?.cancel()
    searchTask = Task { [recipeService] in
      do {
        let search = try await recipeService.searchRecipe(query: trimmedSearch)
        let recipes = search.recipes
        let count = search.count

        await MainActor.run { [weak self] in
          self?.state = .init(
            isLoading: false,
            statusMessage: count == 0 ? "No results for \(trimmedSearch)" : nil ,
            recipes: recipes
          )
        }
      } catch {
        // Could it be an existing issue with the API? when the search matches it returns a 200, but when the query is incomplete or wrong it returns a badrequest error. That is why I am forcing the message.
        await MainActor.run { [weak self] in
          self?.state = .init(
            isLoading: false,
            statusMessage: "No results for \(trimmedSearch)",
            recipes: []
          )
        }
        print(error)
      }
      
    }
  }
}
