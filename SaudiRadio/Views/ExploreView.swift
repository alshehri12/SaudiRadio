import SwiftUI

struct ExploreView: View {
    @ObservedObject var viewModel: RadioViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Categories Section
                    VStack(alignment: .leading) {
                        Text("Browse by Category")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(StationCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category, 
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    // Toggle category selection
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
                    
                    // Trending Stations
                    VStack(alignment: .leading) {
                        Text("Trending Now")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(Array(viewModel.stations.shuffled().prefix(5))) { station in
                                    VStack(alignment: .center) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(.systemGray6))
                                                .frame(width: 120, height: 120)
                                            
                                            Image(station.imageURL)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 90, height: 90)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color(.systemGray3), lineWidth: 1)
                                                )
                                        }
                                        
                                        Text(station.name)
                                            .font(.headline)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                            .frame(width: 120)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 5)
                                    .onTapGesture {
                                        viewModel.playStation(station)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Filtered Stations (if category is selected)
                    if let selectedCategory = viewModel.selectedCategory {
                        VStack(alignment: .leading) {
                            Text(selectedCategory.rawValue + " Stations")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            let filteredStations = viewModel.stations.filter { $0.category == selectedCategory }
                            
                            if filteredStations.isEmpty {
                                Text("No stations found in this category")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(filteredStations) { station in
                                    StationCard(station: station, viewModel: viewModel)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    } else {
                        // All Stations (alphabetical)
                        VStack(alignment: .leading) {
                            Text("All Stations")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.stations.sorted(by: { $0.name < $1.name })) { station in
                                StationCard(station: station, viewModel: viewModel)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Explore")
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

#Preview {
    ExploreView(viewModel: RadioViewModel())
}
