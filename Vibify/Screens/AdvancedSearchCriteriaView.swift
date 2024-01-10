import Foundation
import SwiftUI

struct AdvancedSearchCriteriaView: View {
    @Bindable var viewModel: AdvancedSearchCriteriaVM
    @Environment(\.dismiss) var dismiss
    var updateMainViewModel: (AdvancedSearchCriteriaVM) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                // Decade Slider
                VStack {
                    Text("Decade: \(String(format: "%.0f", viewModel.decade))'s").font(.headline)
                    Slider(value: $viewModel.decade, in: 1860...Double(Date().year), step: 10)
                }
                
                // Number of Songs Slider
                VStack {
                    Text("Number of Songs: \(Int(viewModel.numberOfSongs))").font(.headline)
                    Slider(value: $viewModel.numberOfSongs, in: 0...25, step: 1)
                }
                
                LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                    ForEach(viewModel.genreList, id: \.self) { genre in
                        GenreButton(genre: genre, selectedGenres: $viewModel.selectedGenres)
                    }
                }
                
                MoodSelectorView(
                    selectedMood: $viewModel.searchCriteria.mood
                )
                
                ActivityPickerView(
                    selectedActivity: $viewModel.searchCriteria.activity
                )
                
                TextField(
                    "Favorite Artists",
                    text: $viewModel.searchCriteria.favoriteArtist
                )
                .padding(.top, 8)
            }
            .navigationBarTitle("Advanced Search", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        updateMainViewModel(viewModel)
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: Private
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
}
