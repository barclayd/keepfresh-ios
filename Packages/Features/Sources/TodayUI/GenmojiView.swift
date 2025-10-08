import DesignSystem
import Models
import Network
import SwiftUI

public struct GenmojiView: View {
    private let name: String
    private let fontSize: CGFloat
    private let tint: Color

    @State private var genmojiImage: UIImage?
    @State private var isLoading: Bool = true
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
                    .frame(height: fontSize)
            } else if let error = error {
                Text("Error: \(error)")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .task {
            await fetchGenmoji()
        }
    }

    private func fetchGenmoji() async {
        isLoading = true
        error = nil

        do {
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
