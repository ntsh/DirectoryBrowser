import Foundation

enum SortOption: Equatable {
    case date(ascending: Bool)
    case name(ascending: Bool)
}

extension SortOption {
    func dateButtonIcon() -> String {
        sortConfigs().dateButtonIcon
    }

    func nameButtonIcon() -> String {
        sortConfigs().nameButtonIcon
    }

    func toggleToDateSortOption() -> SortOption {
        sortConfigs().toggleToDateSortOption
    }

    func toggleToNameSortOption() -> SortOption {
        sortConfigs().toggleToNameSortOption
    }

    private func sortConfigs() -> SortConfigs {
        var sorter: SortConfigs

        switch self {
        case .date(ascending: let ascending):
            sorter = ascending ? SortConfigs.dateAscendingSortConfigs : SortConfigs.dateDescendingSortConfigs
        case .name(ascending: let ascending):
            sorter = ascending ? SortConfigs.nameAscendingSortConfigs : SortConfigs.nameDescendingSortConfigs
        }

        return sorter
    }

    private struct SortConfigs {
        var dateButtonIcon: String = ""
        var nameButtonIcon: String = ""
        var toggleToDateSortOption: SortOption
        var toggleToNameSortOption: SortOption

        static let dateDescendingSortConfigs = SortConfigs(dateButtonIcon: "arrow.down",
                                                           toggleToDateSortOption: .date(ascending: true),
                                                           toggleToNameSortOption: .name(ascending: false))
        static let dateAscendingSortConfigs = SortConfigs(dateButtonIcon: "arrow.up",
                                                          toggleToDateSortOption: .date(ascending: false),
                                                          toggleToNameSortOption: .name(ascending: false))
        static let nameDescendingSortConfigs = SortConfigs(nameButtonIcon: "arrow.down",
                                                           toggleToDateSortOption: .date(ascending: false),
                                                           toggleToNameSortOption: .name(ascending: true))
        static let nameAscendingSortConfigs = SortConfigs(nameButtonIcon: "arrow.up",
                                                          toggleToDateSortOption: .date(ascending: false),
                                                          toggleToNameSortOption: .name(ascending: false))
    }
}
