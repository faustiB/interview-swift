
import SwiftUI

//TODO: - #5 Implement the Details screen using RecipeDetailViewModel

struct RecipeDetailView: View {
  @State var viewModel: RecipeDetailViewModel
  
  var body: some View {
    Text(viewModel.recipe.title)
  }
}

#Preview {
  RecipeDetailView(viewModel: RecipeDetailViewModel(recipe: .preview))
}
