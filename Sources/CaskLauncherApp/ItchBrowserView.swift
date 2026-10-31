import SwiftUI
import AppKit
import CaskLauncherCore

struct ItchBrowserView: View {
    @ObservedObject var appState: AppState
    @State private var selectedCategory: ItchCategory = .all
    @State private var games: [ItchGame] = ItchManager.curatedFreeGames
    @State private var currentPage: Int = 1
    @State private var isLoading: Bool = false
    @State private var isLoadingMore: Bool = false
    @State private var canLoadMore: Bool = true
    @State private var searchQuery: String = ""
    @State private var activeSearchTerm: String = ""
    @State private var errorMessage: String?
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            categoryBar
            searchBar
            Divider()
            contentArea
        }
        .frame(minWidth: 940, idealWidth: 1080, maxWidth: 1240, minHeight: 650, idealHeight: 750, maxHeight: 860)
        .background(ArcWickyTheme.Palette.obsidianBase)
        .task {
            await loadCategory(selectedCategory, reset: true)
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack(alignment: .center, spacing: VermutSpace.s4) {
            HStack(spacing: VermutSpace.s2) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.Vermut.amber)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: VermutSpace.s2) {
                        Text("itch.io Free Indie Games")
                            .font(VermutType.headline)
                            .foregroundStyle(Color.Vermut.foreground)
                        VermutBadge(kind: .warning, text: "DRM-Free", showsDot: false)
                    }
                    Text("Search and browse hundreds of thousands of free games directly from itch.io creators.")
                        .font(VermutType.captionRegular)
                        .foregroundStyle(Color.Vermut.mutedForeground)
                }
            }

            Spacer()

            HStack(spacing: VermutSpace.s2) {
                Button {
                    if let url = URL(string: "https://itch.io/games/free") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Open itch.io")
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10))
                    }
                }
                .buttonStyle(VermutButtonStyle(kind: .outline, height: VermutHeight.buttonSmall))
                .help("Open itch.io free games catalog in your browser")

                Button {
                    appState.showingItchBrowser = false
                    appState.showingDrmInstaller = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.square")
                        Text("Install .exe")
                    }
                }
                .buttonStyle(VermutButtonStyle(kind: .outline, height: VermutHeight.buttonSmall))
                .help("Install a downloaded .exe game in a bottle")

                Button("Done") {
                    appState.showingItchBrowser = false
                }
                .buttonStyle(VermutButtonStyle(kind: .primary, height: VermutHeight.buttonSmall))
            }
        }
        .padding(.horizontal, VermutSpace.s6)
        .padding(.vertical, VermutSpace.s4)
    }

    // MARK: - Category Bar
    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: VermutSpace.s2) {
                ForEach(ItchCategory.allCases) { cat in
                    Button {
                        searchQuery = ""
                        activeSearchTerm = ""
                        if selectedCategory != cat {
                            selectedCategory = cat
                            Task { await loadCategory(cat, reset: true) }
                        }
                    } label: {
                        HStack(spacing: VermutSpace.s1) {
                            Image(systemName: cat.iconName)
                                .font(.system(size: 11))
                            Text(cat.rawValue)
                                .font(VermutType.callout)
                        }
                        .padding(.horizontal, VermutSpace.s3)
                        .padding(.vertical, 6)
                        .background(
                            selectedCategory == cat && activeSearchTerm.isEmpty
                                ? Color.Vermut.primary
                                : Color.Vermut.card
                        )
                        .foregroundStyle(
                            selectedCategory == cat && activeSearchTerm.isEmpty
                                ? Color.Vermut.primaryForeground
                                : Color.Vermut.foreground
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    selectedCategory == cat && activeSearchTerm.isEmpty
                                        ? Color.clear
                                        : Color.Vermut.border,
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, VermutSpace.s6)
            .padding(.vertical, VermutSpace.s2)
        }
        .background(Color.Vermut.card.opacity(0.4))
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: VermutSpace.s3) {
            HStack(spacing: VermutSpace.s2) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.Vermut.mutedForeground)
                    .font(.system(size: 13))

                TextField("Search any game on itch.io (e.g. The Baby In Yellow, Fears to Fathom, horror)…", text: $searchQuery)
                    .textFieldStyle(.plain)
                    .font(VermutType.body)
                    .onSubmit {
                        triggerSearch()
                    }

                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                        activeSearchTerm = ""
                        Task { await loadCategory(selectedCategory, reset: true) }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.Vermut.mutedForeground)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, VermutSpace.s3)
            .padding(.vertical, 7)
            .background(Color.Vermut.card)
            .clipShape(RoundedRectangle(cornerRadius: VermutRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: VermutRadius.md)
                    .strokeBorder(Color.Vermut.border, lineWidth: 1)
            )

            Button("Search") {
                triggerSearch()
            }
            .buttonStyle(VermutButtonStyle(kind: .outline, height: VermutHeight.buttonSmall))

            Spacer()

            if isLoading {
                HStack(spacing: VermutSpace.s1) {
                    ProgressView().controlSize(.mini)
                    Text(activeSearchTerm.isEmpty ? "Loading catalog…" : "Searching itch.io…")
                        .font(VermutType.captionRegular)
                        .foregroundStyle(Color.Vermut.mutedForeground)
                }
            } else {
                Text("\(games.count) games")
                    .font(VermutType.captionRegular)
                    .foregroundStyle(Color.Vermut.mutedForeground)
            }
        }
        .padding(.horizontal, VermutSpace.s6)
        .padding(.vertical, VermutSpace.s3)
        .onChange(of: searchQuery) { _, newQuery in
            searchTask?.cancel()
            let q = newQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            if q.isEmpty {
                activeSearchTerm = ""
                Task { await loadCategory(selectedCategory, reset: true) }
            } else {
                searchTask = Task {
                    try? await Task.sleep(nanoseconds: 400_000_000) // 400ms debounce
                    if !Task.isCancelled {
                        await performLiveSearch(q)
                    }
                }
            }
        }
    }

    // MARK: - Content Area
    private var contentArea: some View {
        ScrollView {
            VStack(spacing: VermutSpace.s6) {
                if !activeSearchTerm.isEmpty {
                    HStack {
                        Text("Search results for \"\(activeSearchTerm)\"")
                            .font(VermutType.bodyEmphasis)
                            .foregroundStyle(Color.Vermut.foreground)
                        Spacer()
                    }
                }

                if games.isEmpty && !isLoading {
                    VStack(spacing: VermutSpace.s3) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.Vermut.mutedForeground)
                        Text("No games found for \"\(searchQuery)\"")
                            .font(VermutType.bodyEmphasis)
                            .foregroundStyle(Color.Vermut.foreground)
                        Text("Try searching by creator or general genre, or open itch.io in your browser.")
                            .font(VermutType.captionRegular)
                            .foregroundStyle(Color.Vermut.mutedForeground)
                        Button("Clear search") {
                            searchQuery = ""
                            activeSearchTerm = ""
                            Task { await loadCategory(selectedCategory, reset: true) }
                        }
                        .buttonStyle(VermutButtonStyle(kind: .outline))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, VermutSpace.s8)
                } else {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 240, maximum: 300), spacing: VermutSpace.s4)],
                        spacing: VermutSpace.s4
                    ) {
                        ForEach(games) { game in
                            itchGameCard(game)
                        }
                    }

                    if canLoadMore && activeSearchTerm.isEmpty {
                        loadMoreFooter
                    }
                }
            }
            .padding(VermutSpace.s6)
        }
    }

    // MARK: - Game Card
    private func itchGameCard(_ game: ItchGame) -> some View {
        VStack(alignment: .leading, spacing: VermutSpace.s2) {
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .bottomLeading) {
                    coverView(for: game)
                        .frame(height: 140)
                        .clipped()

                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 50)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                    HStack(spacing: 4) {
                        ForEach(game.platforms.prefix(3), id: \.self) { platform in
                            Text(platform)
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                    }
                    .padding(6)
                }

                Text("FREE")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.Vermut.success.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(6)
            }
            .clipShape(RoundedRectangle(cornerRadius: VermutRadius.sm))

            VStack(alignment: .leading, spacing: 3) {
                Text(game.title)
                    .font(VermutType.bodyEmphasis)
                    .foregroundStyle(Color.Vermut.foreground)
                    .lineLimit(1)

                if let author = game.authorName {
                    Text("by \(author)")
                        .font(VermutType.captionRegular)
                        .foregroundStyle(Color.Vermut.mutedForeground)
                        .lineLimit(1)
                }

                if let desc = game.shortText {
                    Text(desc)
                        .font(VermutType.captionRegular)
                        .foregroundStyle(Color.Vermut.mutedForeground)
                        .lineLimit(2)
                        .padding(.top, 1)
                }
            }
            .padding(.horizontal, VermutSpace.s1)

            Spacer(minLength: 0)

            HStack(spacing: VermutSpace.s2) {
                Button {
                    appState.drmInstallerPreloadedTitle = game.title
                    appState.drmInstallerPreloadedCoverURL = game.coverURL
                    appState.drmInstallerPreloadedWebURL = game.url
                    appState.showingItchBrowser = false
                    appState.showingDrmInstaller = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 10))
                        Text("Install Game")
                    }
                }
                .buttonStyle(VermutButtonStyle(
                    kind: .primary,
                    height: VermutHeight.buttonSmall,
                    fillWidth: true
                ))

                Button {
                    NSWorkspace.shared.open(game.url)
                } label: {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10))
                }
                .buttonStyle(VermutButtonStyle(
                    kind: .outline,
                    height: VermutHeight.buttonSmall
                ))
                .help("Open page on itch.io")
            }
        }
        .padding(VermutSpace.s3)
        .background(Color.Vermut.card)
        .clipShape(RoundedRectangle(cornerRadius: VermutRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: VermutRadius.md)
                .strokeBorder(Color.Vermut.border, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func coverView(for game: ItchGame) -> some View {
        if let coverURL = game.coverURL {
            AsyncImage(url: coverURL) { phase in
                switch phase {
                case .success(let img):
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    fallbackCover
                case .empty:
                    Rectangle()
                        .fill(Color.Vermut.muted)
                @unknown default:
                    fallbackCover
                }
            }
        } else {
            fallbackCover
        }
    }

    private var fallbackCover: some View {
        ZStack {
            Color.Vermut.surface
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.Vermut.mutedForeground.opacity(0.3))
        }
    }

    // MARK: - Load More Footer
    private var loadMoreFooter: some View {
        VStack(spacing: VermutSpace.s2) {
            Button {
                Task { await loadMore() }
            } label: {
                if isLoadingMore {
                    HStack(spacing: VermutSpace.s2) {
                        ProgressView().controlSize(.small)
                        Text("Loading more free games…")
                    }
                } else {
                    HStack(spacing: VermutSpace.s2) {
                        Image(systemName: "arrow.down.circle")
                        Text("Load More Games (Page \(currentPage + 1))")
                    }
                }
            }
            .buttonStyle(VermutButtonStyle(kind: .outline, height: VermutHeight.button))
            .disabled(isLoadingMore || isLoading)
        }
        .padding(.top, VermutSpace.s4)
    }

    // MARK: - Actions
    private func triggerSearch() {
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        Task { await performLiveSearch(q) }
    }

    private func performLiveSearch(_ query: String) async {
        isLoading = true
        activeSearchTerm = query
        defer { isLoading = false }

        do {
            let results = try await ItchManager.shared.searchGames(query: query)
            await MainActor.run {
                self.games = results
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func loadCategory(_ category: ItchCategory, reset: Bool = true) async {
        if reset {
            currentPage = 1
            canLoadMore = true
        }
        isLoading = true
        defer { isLoading = false }

        do {
            let fetched = try await ItchManager.shared.fetchGames(category: category, page: 1)
            await MainActor.run {
                if !fetched.isEmpty {
                    self.games = fetched
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func loadMore() async {
        guard !isLoadingMore, canLoadMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1
        do {
            let more = try await ItchManager.shared.fetchGames(category: selectedCategory, page: nextPage)
            await MainActor.run {
                if more.isEmpty {
                    self.canLoadMore = false
                } else {
                    let existingIds = Set(self.games.map { $0.id })
                    let uniqueNew = more.filter { !existingIds.contains($0.id) }
                    if uniqueNew.isEmpty {
                        self.canLoadMore = false
                    } else {
                        self.games.append(contentsOf: uniqueNew)
                        self.currentPage = nextPage
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.canLoadMore = false
            }
        }
    }
}
