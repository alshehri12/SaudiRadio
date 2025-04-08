import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: RadioViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Featured Stations
                    VStack(alignment: .leading) {
                        Text("Featured Stations")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(viewModel.stations.prefix(5)) { station in
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
                                        
                                        Button(action: {
                                            viewModel.playStation(station)
                                        }) {
                                            HStack {
                                                Image(systemName: viewModel.isCurrentlyPlaying(station) ? "pause.fill" : "play.fill")
                                                    .font(.system(size: 12))
                                                Text(viewModel.isCurrentlyPlaying(station) ? "Pause" : "Play")
                                                    .font(.system(size: 14, weight: .medium))
                                            }
                                            .foregroundColor(.white)
                                            .frame(width: 100, height: 36)
                                            .background(Color.accentColor)
                                            .cornerRadius(18)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 5)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Most Popular
                    VStack(alignment: .leading) {
                        Text("Most Popular")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.stations.prefix(3)) { station in
                            StationCard(station: station, viewModel: viewModel)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Categories
                    VStack(alignment: .leading) {
                        Text("Categories")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(StationCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category, 
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    viewModel.selectCategory(category)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recently Played
                    VStack(alignment: .leading) {
                        Text("Recently Played")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if let currentStation = AudioPlayerManager.shared.currentStation {
                            StationCard(station: currentStation, viewModel: viewModel)
                                .padding(.horizontal)
                        } else {
                            Text("No recently played stations")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Saudi Radio")
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
    HomeView(viewModel: RadioViewModel())
}
