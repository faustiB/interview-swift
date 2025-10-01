
import Foundation

@MainActor
final class RecipeDetailViewModel: ObservableObject {
  private let recipeId: String
  private let service: RecipeService
  
  @Published var isLoading: Bool = false
  @Published var recipeDetails: Recipe?
  
  init(recipeId: String, service: RecipeService = RecipeService()) {
    self.recipeId = recipeId
    self.service = service
    
    // Load the recipe details once viewmodel is instantiated
    Task {
      await fetchRecipeDetails()
    }
  }

  func fetchRecipeDetails() async {
    isLoading = true
    do {
      let recipeFetched = try await service.fetchRecipeDetails(id: recipeId)
      recipeDetails = recipeFetched
      isLoading = false
    } catch {
      isLoading = false
      print(error)
    }
    
  }
}
