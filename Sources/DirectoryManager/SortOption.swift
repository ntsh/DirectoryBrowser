import Foundation

/// Options describing how ``DocumentsStore`` sorts its items.
public enum SortOption: Equatable {
    /// Sort by modification date.
    case date(ascending: Bool)
    /// Sort alphabetically by name.
    case name(ascending: Bool)
}

public extension SortOption {
    /// System image name representing the date sort icon.
    func dateButtonIcon() -> String {
        sortConfigs().dateButtonIcon
    }

    /// System image name representing the name sort icon.
    func nameButtonIcon() -> String {
        sortConfigs().nameButtonIcon
    }

    /// Returns the ``SortOption`` toggled to the opposite date order.
    func toggleToDateSortOption() -> SortOption {
        sortConfigs().toggleToDateSortOption
    }

    /// Returns the ``SortOption`` toggled to the opposite name order.
    func toggleToNameSortOption() -> SortOption {
        sortConfigs().toggleToNameSortOption
    }

    /// Comparator used for sorting ``Document`` objects.
    func sortingComparator() -> (Document, Document) -> Bool {
        return sortConfigs().comparator
    }

    private func sortConfigs() -> SortConfigs {
        var sortConfig: SortConfigs

        switch self {
        case .date(ascending: let ascending):
            sortConfig = ascending ? SortConfigs.dateAscendingSortConfigs : SortConfigs.dateDescendingSortConfigs
        case .name(ascending: let ascending):
            sortConfig = ascending ? SortConfigs.nameAscendingSortConfigs : SortConfigs.nameDescendingSortConfigs
        }

        return sortConfig
    }

    private struct SortConfigs {
        var dateButtonIcon: String = ""
        var nameButtonIcon: String = ""
        var toggleToDateSortOption: SortOption
        var toggleToNameSortOption: SortOption
        var comparator: (Document, Document) -> Bool

        private static let dateSorterAscending = { (doc1: Document, doc2: Document) -> Bool in
            guard let date1 = doc1.modified, let date2 = doc2.modified else {
                return true
            }
            return date1 < date2
        }

        private static let dateSorterDescending = { (doc1: Document, doc2: Document) -> Bool in
            guard let date1 = doc1.modified, let date2 = doc2.modified else {
                return false
            }
            return date1 > date2
        }

        private static let nameSorterAscending = { (doc1: Document, doc2: Document) -> Bool in
            return (doc1.name.caseInsensitiveCompare(doc2.name) == .orderedAscending) == true
        }

        private static let nameSorterDescending = { (doc1: Document, doc2: Document) -> Bool in
            return (doc1.name.caseInsensitiveCompare(doc2.name) == .orderedAscending) == false
        }

        static let dateDescendingSortConfigs = SortConfigs(dateButtonIcon: "arrow.down",
                                                           toggleToDateSortOption: .date(ascending: true),
                                                           toggleToNameSortOption: .name(ascending: false),
                                                           comparator: dateSorterDescending)

        static let dateAscendingSortConfigs = SortConfigs(dateButtonIcon: "arrow.up",
                                                          toggleToDateSortOption: .date(ascending: false),
                                                          toggleToNameSortOption: .name(ascending: false),
                                                          comparator: dateSorterAscending)

        static let nameDescendingSortConfigs = SortConfigs(nameButtonIcon: "arrow.down",
                                                           toggleToDateSortOption: .date(ascending: false),
                                                           toggleToNameSortOption: .name(ascending: true),
                                                           comparator: nameSorterDescending)

        static let nameAscendingSortConfigs = SortConfigs(nameButtonIcon: "arrow.up",
                                                          toggleToDateSortOption: .date(ascending: false),
                                                          toggleToNameSortOption: .name(ascending: false),
                                                          comparator: nameSorterAscending)
    }
}
