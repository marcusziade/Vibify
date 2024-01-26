import Foundation

extension String {
    /// A normalized version of the string, suitable for comparison and search operations.
    func normalizedForSearch() -> String {
        return self.folding(
            options: [
                .diacriticInsensitive,
                .caseInsensitive,
                .widthInsensitive
            ],
            locale: .current
        )
    }
}

extension String: PlaylistCriteria {
    
    func toPrompt() -> String {
        self
    }
}
