import Foundation
import SwiftUI

struct AdvancedSearchCriteriaView: View {
    @Bindable var viewModel: AdvancedSearchCriteriaVM
    @Environment(\.dismiss) var dismiss
    var updateMainViewModel: (AdvancedSearchCriteriaVM) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    DecadePickerView(
                        selectedDecade: $viewModel.decade,
                        startYear: 1860,
                        endYear: Date().year,
                        step: 10
                    )
                    
                    NumberOfSongsCounterView(numberOfSongs: Binding<Int>(
                        get: { Int(viewModel.numberOfSongs) },
                        set: { viewModel.numberOfSongs = Double($0) }
                    ))
                    .padding(.bottom, 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Genres")
                            .padding(.horizontal, 4)
                            .font(.headline)
                        TagLayoutView(
                            tags: viewModel.genreList.sorted(),
                            onTap: { viewModel.selectGenre($0) },
                            selectedTags: Array(viewModel.selectedGenres)
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mood and Activity")
                            .padding(.horizontal, 4)
                            .font(.headline)
                        TagLayoutView(
                            tags: ["Chill", "Energetic", "Melancholic"],
                            onTap: { viewModel.selectedMood = $0 },
                            selectedTags: [viewModel.selectedMood]
                        )
                        
                        TagLayoutView(
                            tags: ["Workout", "Study", "Party"],
                            onTap: { viewModel.selectedActivity = $0 },
                            selectedTags: [viewModel.selectedActivity]
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    FavoriteArtistTextField(favoriteArtist: $viewModel.searchCriteria.favoriteArtist)
                        .padding(.bottom)
                }
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
}

#Preview {
    AdvancedSearchCriteriaView(
        viewModel: AdvancedSearchCriteriaVM(),
        updateMainViewModel: { _ in }
    )
    .preferredColorScheme(.dark)
}
