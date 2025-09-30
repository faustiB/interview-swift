
import SwiftUI
import Combine
import Foundation

struct RecipeListView: View {
  @StateObject private var viewModel = RecipeListViewModel()

    var body: some View {
        NavigationView {
            // TODO: - #3: Display a search bar and a list of results.
            //  - perform the search using the view model
            //  - The view should match the image in screenshots/swiftui_search_results.png
          
          Group {
            if viewModel.recipeSearchQuery.isEmpty {
              Color.clear
            } else if viewModel.state.isLoading {
              ProgressView()
                .progressViewStyle(.circular)
            } else if viewModel.recipeSearchQuery.isEmpty {
              Color.clear
            } else if let statusMessage = viewModel.state.statusMessage {
              // no search found --> status message
            } else {
              List (viewModel.state.recipes) { recipe in
                NavigationLink(destination: RecipeDetailView(viewModel: RecipeDetailViewModel(recipe: recipe))) {
                  Text(recipe.title)
                }
              }
            }
            
          }
          .navigationTitle("Recipes")
          .searchable(text: $viewModel.recipeSearchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Recipes")
        }
    }
}

#Preview {
  RecipeListView()
}
