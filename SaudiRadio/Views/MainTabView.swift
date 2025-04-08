import SwiftUI

struct MainTabView: View {
    @StateObject var viewModel = RadioViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(viewModel: viewModel)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                
                ExploreView(viewModel: viewModel)
                    .tabItem {
                        Label("Explore", systemImage: "safari")
                    }
                    .tag(1)
                
                FavoritesView(viewModel: viewModel)
                    .tabItem {
                        Label("Favorites", systemImage: "heart")
                    }
                    .tag(2)
                
                SearchView(viewModel: viewModel)
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(3)
            }
            .padding(.bottom, AudioPlayerManager.shared.currentStation != nil ? 60 : 0)
            
            // Mini Player
            MiniPlayerView()
        }
    }
}

#Preview {
    MainTabView()
}
