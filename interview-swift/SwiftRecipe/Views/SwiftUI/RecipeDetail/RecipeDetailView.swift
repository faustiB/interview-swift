
import SwiftUI

//TODO: - #5 Implement the Details screen using RecipeDetailViewModel

struct RecipeDetailView: View {
  @ObservedObject var viewModel: RecipeDetailViewModel
  
  var body: some View {
    Group {
      if viewModel.isLoading {
        ProgressView()
          .progressViewStyle(.circular)
      } else if let recipeDetails = viewModel.recipeDetails {
        RecipeDetailsInfoView(recipe: recipeDetails)
          .navigationTitle(recipeDetails.title)
          .navigationBarTitleDisplayMode(.inline)
      } else {
        EmptyView()
      }
    }
  }
}

struct RecipeDetailsInfoView: View {
  let recipe: Recipe
  
  var body: some View {
    VStack {
      RecipeHeroImage(recipe: recipe)
      
      VStack(alignment: .leading) {
        HStack(alignment: .center) {
          Text("Social Rank:")
            .bold()
          
          Spacer()
          
          StarRatingView(socialRank: recipe.socialRank)
            .foregroundStyle(.yellow)
            .padding(.top, 8)
        }
        
        IngredientsListView(recipe: recipe)
        
        Spacer()
        
        Link(destination: recipe.sourceURL) {
          Text("View Full Recipe")
            .font(.headline)
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
      }
      .padding(.horizontal, 16)
      .frame(maxWidth: .infinity)
      
    }
  }
}

struct RecipeHeroImage: View {
  let recipe: Recipe
  
  var body: some View {
    ZStack(alignment: .bottomLeading) {
      VStack (alignment: .leading) {
        AsyncImage(url: recipe.imageURL) { image in
          image
            .resizable()
            .scaledToFill()
        } placeholder: {
          Image(systemName: "oven.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 230, height: 230)
            .foregroundColor(.gray)
        }
        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: 6)
        )
      }
      
      HStack(spacing: 8) {
        Text("Published by")
        
        Text(recipe.publisher)
          .foregroundStyle(.blue)
          .bold()
      }
      .padding(.leading, 16)
      .padding(.vertical, 16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(.gray.opacity(0.85))
    }
  }
  
}

struct StarRatingView: View {
  let socialRank: Double
  
  // Social Rank max is 100, so in order to have 5 stars it is divided by 20.
  private var converted5StarsRating: Double {
    socialRank / 20
  }
  
  var body: some View {
    HStack(alignment: .center ,spacing: 2) {
      ForEach(0..<5, id: \.self) { index in
        Image(systemName: starType(index: index))
      }
    }
  }
  
  private func starType(index: Int) -> String {
    let starFilledValue = converted5StarsRating - Double(index)
    
    if starFilledValue >= 1 {
      return "star.fill"
    } else if starFilledValue >= 0 {
      return "star.leadinghalf.filled"
    } else {
      return "star"
    }
  }
}

struct IngredientsListView: View {
  let recipe: Recipe
  
  var body: some View {
    Text("Ingredients:")
      .bold()
      .padding(.top, 8)
    
    if let ingredients = recipe.ingredients {
      ForEach(ingredients, id: \.self) { ingredient in
        Text("- \(ingredient)")
          .lineLimit(2)
      }
      .padding(.leading, 16)
    }
  }
}

#Preview {
  RecipeDetailView(viewModel: RecipeDetailViewModel(recipeId: Recipe.preview.id))
}
