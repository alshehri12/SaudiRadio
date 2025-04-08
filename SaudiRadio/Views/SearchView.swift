import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: RadioViewModel
    @State private var searchText = ""
    @State private var recentSearches: [String] = UserDefaults.standard.stringArray(forKey: "recentSearches") ?? []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Stations, tracks, podcasts...", text: $searchText)
                            .onChange(of: searchText) { oldValue, newValue in
                                viewModel.searchText = newValue
                            }
                            .onSubmit {
                                if !searchText.isEmpty && !recentSearches.contains(searchText) {
                                    recentSearches.insert(searchText, at: 0)
                                    if recentSearches.count > 5 {
                                        recentSearches.removeLast()
                                    }
                                    UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
                                }
                            }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // "Saudi Radio Finder" Feature
                    VStack(alignment: .leading) {
                        Text("Saudi Radio Finder")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Button(action: {
                            // This would trigger audio recognition in a real app
                        }) {
                            HStack {
                                Image(systemName: "waveform.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .padding(.leading)
                                
                                VStack(alignment: .leading) {
                                    Text("What's this station?")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text("Tap to identify radio stations")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.purple)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    
                    // Recent Searches
                    if !recentSearches.isEmpty && searchText.isEmpty {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Recent searches")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button(action: {
                                    recentSearches.removeAll()
                                    UserDefaults.standard.removeObject(forKey: "recentSearches")
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                            
                            ForEach(recentSearches, id: \.self) { search in
                                HStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Text(String(search.prefix(1)).uppercased())
                                                .fontWeight(.bold)
                                                .foregroundColor(.gray)
                                        )
                                    
                                    Text(search)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        searchText = search
                                        viewModel.searchText = search
                                    }) {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    
                    // Genres
                    VStack(alignment: .leading) {
                        Text("Genres")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(StationCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    if viewModel.selectedCategory == category {
                                        viewModel.selectCategory(nil)
                                    } else {
                                        viewModel.selectCategory(category)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Search Results
                    if !searchText.isEmpty || viewModel.selectedCategory != nil {
                        VStack(alignment: .leading) {
                            Text("Results")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            if viewModel.filteredStations.isEmpty {
                                Text("No stations found")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(viewModel.filteredStations) { station in
                                    StationCard(station: station, viewModel: viewModel)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.top)
                .navigationTitle("Search")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .font(.title3)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {}) {
                            Image(systemName: "person.circle")
                                .font(.title3)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SearchView(viewModel: RadioViewModel())
}
