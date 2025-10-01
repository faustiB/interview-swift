
import SwiftUI
import Combine
import Foundation

struct RecipeListView: View {
  @StateObject private var viewModel = RecipeListViewModel()

    var body: some View {
        NavigationView {
          Group {
            if viewModel.recipeSearchQuery.isEmpty {
              Color.clear
            } else if viewModel.state.isLoading {
              ProgressView()
                .progressViewStyle(.circular)
            } else if viewModel.recipeSearchQuery.isEmpty {
              Color.clear
            } else if let statusMessage = viewModel.state.statusMessage {
              HStack {
                Text(statusMessage)
                  .font(.body)
              }
              .frame(maxWidth: .infinity)
            } else {
              List (viewModel.state.recipes) { recipe in
                NavigationLink {
                  LazyView {
                    RecipeDetailView(viewModel: RecipeDetailViewModel(recipeId: recipe.id))
                  }
                } label: {
                  RecipelistRow(recipe: recipe)
                }
              }
              .listStyle(.plain)
            }
            
          }
          .navigationTitle("Recipes")
          .searchable(text: $viewModel.recipeSearchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Recipes...")
          .searchPresentationToolbarBehavior(.avoidHidingContent)
          .navigationBarTitleDisplayMode(.automatic)
        }
    }
}

struct RecipelistRow: View {
  let recipe: Recipe
  
  var body: some View {
    HStack(spacing: 12) {
      // Recipe image
      AsyncImage(url: recipe.imageURL) { image in
        image
          .resizable()
          .scaledToFill()
      } placeholder: {
        Image(systemName: "oven.fill")
          .foregroundColor(.gray)
      }
      .frame(width: 50, height: 50)
      .clipShape(RoundedRectangle(cornerRadius: 6))
      
      // Recipe info
      VStack(alignment: .leading, spacing: 4) {
        Text(recipe.title)
          .font(.body)
          .lineLimit(2)
        
        Text(recipe.publisher)
          .font(.caption)
        
      }

    }
  }
}

// MARK: - Helpers -
struct LazyView <T> : View where T : View {
  var view: () -> T
  var body: some View {
    self.view()
  }
}

#Preview {
  RecipeListView()
}
