
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
            if viewModel.state.isLoading {
              Text("Loading...")
              ProgressView()
                .progressViewStyle(.circular)
            } else if viewModel.recipeSearchQuery.isEmpty {
              Color.clear
            } else if let statusMessage = viewModel.state.statusMessage {
              // no search found --> status message
            } else {
              // returned recipes
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
