import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: RadioViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if viewModel.favoriteStations.isEmpty {
                        VStack(spacing: 15) {
                            Spacer()
                                .frame(height: 50)
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.gray.opacity(0.3))
                            
                            Text("No Favorite Stations")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Add stations to your favorites by tapping the heart icon")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 40)
                            
                            Button(action: {
                                // Go to search view logic would be here in a real app
                            }) {
                                Text("Discover Stations")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.accentColor)
                                    .cornerRadius(25)
                            }
                            .padding(.top, 10)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        ForEach(viewModel.favoriteStations) { station in
                            StationCard(station: station, viewModel: viewModel)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Favorites")
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
    FavoritesView(viewModel: RadioViewModel())
}
