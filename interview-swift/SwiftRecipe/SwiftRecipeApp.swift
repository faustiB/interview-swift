
import SwiftUI

@main
struct SwiftRecipeApp: App {
    var body: some Scene {
        WindowGroup {
          RecipeListView()
            .tabItem {
              Label("SwiftUI", systemImage: "swift")
            }
        }
    }
}
