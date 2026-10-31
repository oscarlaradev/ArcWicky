import SwiftUI
import CaskLauncherCore

struct DependenciesSheet: View {
    @ObservedObject var appState: AppState
    let store: GameStore?
    let customBottleID: UUID?
    @Environment(\.dismiss) private var dismiss

    @State private var installingVerbs: Set<String> = []
    @State private var statusMessages: [String: String] = [:]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: VermutSpace.s1) {
                    Text("Windows Dependencies & Runtimes")
                        .font(VermutType.headline)
                        .foregroundStyle(Color.Vermut.foreground)
                    Text("One-click installation of Visual C++, DirectX, and .NET components for this bottle.")
                        .font(VermutType.captionRegular)
                        .foregroundStyle(Color.Vermut.mutedForeground)
                }
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(VermutButtonStyle(kind: .outline, height: VermutHeight.buttonSmall))
            }
            .padding(VermutSpace.s6)
            .background(Color.Vermut.surface)

            Divider()

            // List of dependencies
            ScrollView {
                VStack(spacing: VermutSpace.s4) {
                    ForEach(BottleDependency.DependencyCategory.allCases, id: \.self) { category in
                        VStack(alignment: .leading, spacing: VermutSpace.s2) {
                            Text(category.rawValue.uppercased())
                                .font(VermutType.section)
                                .foregroundStyle(Color.Vermut.mutedForeground)
                                .padding(.horizontal, VermutSpace.s2)

                            VStack(spacing: 1) {
                                ForEach(dependencies(for: category)) { dep in
                                    dependencyRow(dep)
                                }
                            }
                            .background(Color.Vermut.surface)
                            .clipShape(RoundedRectangle(cornerRadius: VermutRadius.md))
                        }
                    }
                }
                .padding(VermutSpace.s6)
            }
        }
        .frame(width: 600, height: 500)
        .background(ArcWickyTheme.Palette.obsidianBase)
    }

    private func dependencies(for category: BottleDependency.DependencyCategory) -> [BottleDependency] {
        WinetricksManager.standardDependencies.filter { $0.category == category }
    }

    private func dependencyRow(_ dep: BottleDependency) -> some View {
        HStack(spacing: VermutSpace.s4) {
            VStack(alignment: .leading, spacing: 2) {
                Text(dep.name)
                    .font(VermutType.bodyEmphasis)
                    .foregroundStyle(Color.Vermut.foreground)
                Text(dep.description)
                    .font(VermutType.captionRegular)
                    .foregroundStyle(Color.Vermut.mutedForeground)
                if let status = statusMessages[dep.verb] {
                    Text(status)
                        .font(VermutType.captionRegular)
                        .foregroundStyle(Color.Vermut.amber)
                }
            }

            Spacer()

            if installingVerbs.contains(dep.verb) {
                ProgressView()
                    .controlSize(.small)
            } else {
                Button("Install") {
                    install(dep)
                }
                .buttonStyle(VermutButtonStyle(kind: .outline, height: VermutHeight.buttonSmall))
            }
        }
        .padding(.horizontal, VermutSpace.s4)
        .padding(.vertical, VermutSpace.s3)
    }

    private func install(_ dep: BottleDependency) {
        installingVerbs.insert(dep.verb)
        statusMessages[dep.verb] = "Installing..."

        Task {
            let prefixURL: URL
            if let store = store {
                prefixURL = PathManager.shared.prefixURL(for: store)
            } else if let id = customBottleID {
                prefixURL = PathManager.shared.customPrefixURL(id: id)
            } else {
                prefixURL = PathManager.shared.prefixURL(for: .epic)
            }

            let layout = PathManager.shared.engineLayout(for: .grappleWine)
            guard let wine = layout?.wine64Executable ?? layout?.wineExecutable ?? PathManager.shared.wineExecutable(engine: .grappleWine) else {
                await MainActor.run {
                    installingVerbs.remove(dep.verb)
                    statusMessages[dep.verb] = "Wine not found."
                }
                return
            }

            do {
                try await WinetricksManager.shared.install(
                    verb: dep.verb,
                    prefixURL: prefixURL,
                    wineExecutable: wine,
                    wineserverExecutable: layout?.wineserverExecutable
                )
                await MainActor.run {
                    installingVerbs.remove(dep.verb)
                    statusMessages[dep.verb] = "Installed successfully ✓"
                }
            } catch {
                await MainActor.run {
                    installingVerbs.remove(dep.verb)
                    statusMessages[dep.verb] = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
