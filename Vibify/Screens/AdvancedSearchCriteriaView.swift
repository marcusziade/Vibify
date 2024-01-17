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
                    
                    TagLayoutView(
                        tags: viewModel.genreList.sorted(),
                        onTap: { viewModel.selectGenre($0) },
                        selectedTags: Array(viewModel.selectedGenres)
                    )
                    .padding(.horizontal, 16)
                    
                    MoodSelectorView(
                        selectedMood: $viewModel.searchCriteria.mood
                    )
                    
                    ActivityPickerView(
                        selectedActivity: $viewModel.searchCriteria.activity
                    )
                    .padding(.top, -24)
                    
                    FavoriteArtistTextField(favoriteArtist: $viewModel.searchCriteria.favoriteArtist)
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
    
    // MARK: Private
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
}

#Preview {
    AdvancedSearchCriteriaView(
        viewModel: AdvancedSearchCriteriaVM(),
        updateMainViewModel: { _ in }
    )
    .preferredColorScheme(.dark)
}
