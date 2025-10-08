import DesignSystem
import Models
import Network
import SwiftData
import SwiftUI

public struct GenmojiView: View {
    @Environment(\.modelContext) private var modelContext

    private let name: String
    private let fontSize: CGFloat
    private let tint: Color

    @State private var genmojiImage: UIImage?
    @State private var isLoading: Bool = false
    @State private var error: String?

    public init(name: String, fontSize: CGFloat, tint: Color) {
        self.name = name
        self.fontSize = fontSize
        self.tint = tint
    }

    public var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .tint(tint)
            } else if let genmojiImage = genmojiImage {
                Image(uiImage: genmojiImage)
                    .resizable()
                    .scaledToFit()
            } else if let error = error {
                Text("Error: \(error)")
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                Color.clear
            }
        }.frame(width: fontSize, height: fontSize)
        .task {
            await fetchGenmoji()
        }
    }

    private func fetchGenmoji() async {
        error = nil

        do {
            let descriptor = FetchDescriptor<GenmojiCache>(
                predicate: #Predicate { $0.name == name }
            )

            if let cached = try modelContext.fetch(descriptor).first {
                guard let uiImage = UIImage(data: cached.imageData) else {
                    throw NSError(
                        domain: "GenmojiView",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to create UIImage from cached data"]
                    )
                }

                await MainActor.run {
                    genmojiImage = uiImage
                }
                return
            }

            await MainActor.run {
                isLoading = true
            }

            let api = KeepFreshAPI()
            let response = try await api.getGenmoji(name: name)

            guard let imageData = response.imageContentData else {
                throw NSError(
                    domain: "GenmojiView",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to decode base64 image content"]
                )
            }

            guard let uiImage = UIImage(data: imageData) else {
                throw NSError(
                    domain: "GenmojiView",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to create UIImage from genmoji"]
                )
            }

            // 3. Save to cache
            let cache = GenmojiCache(name: name, imageData: imageData)
            modelContext.insert(cache)
            try modelContext.save()

            await MainActor.run {
                genmojiImage = uiImage
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }
}
