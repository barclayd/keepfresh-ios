import Models
import Network
import SwiftUI
import UniformTypeIdentifiers

public struct DebugView: View {
    @State private var inputText: NSAttributedString? = NSAttributedString(string: "")
    @State private var extractedMetadata: [GenmojiDatabaseModel] = []
    @State private var reconstructedText: NSAttributedString?
    @State private var genmojiName: String = ""
    @State private var isUploading: Bool = false
    @State private var uploadError: String?
    @State private var uploadSuccess: Bool = false
    @State private var fetchedGenmoji: NSAttributedString?
    @State private var isFetchingGenmoji: Bool = false
    @State private var fetchError: String?

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fetched Genmoji")
                        .font(.headline)

                    if isFetchingGenmoji {
                        HStack {
                            ProgressView()
                                .progressViewStyle(.circular)
                            Text("Fetching genmoji...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let error = fetchError {
                        Text("Error: \(error)")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Divider()

                // MARK: - Input Section

                VStack(alignment: .leading, spacing: 8) {
                    Text("Input Text with Genmoji")
                        .font(.headline)

                    TextField("Genmoji Name", text: $genmojiName)
                        .textFieldStyle(.roundedBorder)
                        .disabled(isUploading)

                    CustomTextEditor(text: $inputText)
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))

                    Button("Extract for Database") {
                        extractForDatabase()
                    }
                    .buttonStyle(.glass)
                    .tint(.red)

                    if isUploading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(.circular)
                            Text("Uploading...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if uploadSuccess {
                        Text("Upload successful")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }

                    if let error = uploadError {
                        Text("Error: \(error)")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                // MARK: - Database Metadata

                if !extractedMetadata.isEmpty {
                    Divider()

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Database Storage (\(extractedMetadata.count) Genmoji)")
                            .font(.headline)

                        Text("✓ Data printed to console")
                            .font(.caption)
                            .foregroundStyle(.green)

                        ForEach(extractedMetadata) { metadata in
                            DatabaseCard(metadata: metadata)
                        }
                    }

                    // MARK: - Reconstruction Test

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reconstruction Test")
                            .font(.headline)

                        Button("Reconstruct from Database") {
                            reconstructFromDatabase()
                        }
                        .buttonStyle(.bordered)

                        if let reconstructed = reconstructedText {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Rendered with UILabel:")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                GenmojiLabel(attributedText: reconstructed, fontSize: 36)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)

                                Text("✓ Successfully reconstructed from database data")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Genmoji Database")
    }

    // MARK: - Extract for Database

    private func extractForDatabase() {
        guard let text = inputText else { return }

        // Reset upload states
        uploadError = nil
        uploadSuccess = false

        var results: [GenmojiDatabaseModel] = []
        let plainText = text.string

        print("\n" + String(repeating: "=", count: 60))
        print("📊 EXTRACTING GENMOJI FOR DATABASE")
        print(String(repeating: "=", count: 60))
        print("Plain Text: \(plainText)")
        print(String(repeating: "-", count: 60))

        text.enumerateAttribute(
            .adaptiveImageGlyph,
            in: NSRange(location: 0, length: text.length)
        ) { value, range, _ in
            guard let glyph = value as? NSAdaptiveImageGlyph else { return }

            let model = GenmojiDatabaseModel(
                contentIdentifier: glyph.contentIdentifier,
                contentDescription: glyph.contentDescription,
                imageContent: glyph.imageContent,
                contentType: NSAdaptiveImageGlyph.contentType,
                location: range.location,
                length: range.length
            )

            results.append(model)

            // Print database-ready data
            print("\n🗄️  GENMOJI #\(results.count) - DATABASE RECORD")
            print(String(repeating: "-", count: 60))
            print("Field: content_identifier")
            print("Value: \(model.contentIdentifier)")
            print("Type:  TEXT (UUID)")
            print("")
            print("Field: content_description")
            print("Value: \(model.contentDescription)")
            print("Type:  TEXT")
            print("")
            print("Field: image_content")
            print(model.imageContent)
            print("Type:  BYTEA")
            print("")
            print("Field: content_type")
            print("Value: \(model.contentType.identifier)")
            print("Type:  TEXT")
            print("")
            print("Field: location")
            print("Value: \(model.location)")
            print("Type:  INTEGER")
            print("")
            print("Field: length")
            print("Value: \(model.length)")
            print("Type:  INTEGER")
            print(String(repeating: "-", count: 60))
        }

        extractedMetadata = results

        print("\n" + String(repeating: "=", count: 60))
        print("✅ EXTRACTION COMPLETE")
        print("Total Genmoji: \(results.count)")
        print("Ready for database insert")
        print(String(repeating: "=", count: 60) + "\n")

        // Upload to API
        if !results.isEmpty {
            uploadGenmojiToAPI(results: results)
        }
    }

    private func uploadGenmojiToAPI(results: [GenmojiDatabaseModel]) {
        Task {
            isUploading = true
            uploadError = nil
            uploadSuccess = false

            do {
                let api = KeepFreshAPI()

                print("\n" + String(repeating: "=", count: 60))
                print("🚀 UPLOADING GENMOJI TO API")
                print(String(repeating: "=", count: 60))

                for (index, genmoji) in results.enumerated() {
                    let request = GenmojiUploadRequest(
                        name: genmojiName,
                        contentIdentifier: genmoji.contentIdentifier,
                        contentDescription: genmoji.contentDescription,
                        imageContent: genmoji.imageContent,
                        contentType: genmoji.contentType.identifier
                    )

                    print("\n📤 Uploading Genmoji #\(index + 1)")
                    print("Name: \(genmojiName)")
                    print("Description: \(genmoji.contentDescription)")

                    try await api.uploadGenmoji(request)

                    print("✅ Successfully uploaded Genmoji #\(index + 1)")
                }

                print("\n" + String(repeating: "=", count: 60))
                print("✅ ALL GENMOJI UPLOADED SUCCESSFULLY")
                print(String(repeating: "=", count: 60) + "\n")

                await MainActor.run {
                    uploadSuccess = true
                    isUploading = false
                }
            } catch {
                print("\n" + String(repeating: "=", count: 60))
                print("❌ UPLOAD FAILED")
                print("Error: \(error.localizedDescription)")
                print(String(repeating: "=", count: 60) + "\n")

                await MainActor.run {
                    uploadError = error.localizedDescription
                    isUploading = false
                }
            }
        }
    }

    // MARK: - Reconstruct from Database

    private func reconstructFromDatabase() {
        guard let text = inputText else { return }

        print("\n" + String(repeating: "=", count: 60))
        print("🔄 RECONSTRUCTING FROM DATABASE")
        print(String(repeating: "=", count: 60))

        let plainText = text.string
        let mutableAttrString = NSMutableAttributedString(string: plainText)

        for (index, metadata) in extractedMetadata.enumerated() {
            // Reconstruct NSAdaptiveImageGlyph from database data
            let glyph = NSAdaptiveImageGlyph(imageContent: metadata.imageContent)

            print("\n✓ Reconstructed Genmoji #\(index + 1)")
            print("  Content ID: \(glyph.contentIdentifier)")
            print("  Description: \(glyph.contentDescription)")
            print("  Match: \(glyph.contentIdentifier == metadata.contentIdentifier ? "✓" : "✗")")

            // Add to attributed string
            mutableAttrString.addAttribute(
                .adaptiveImageGlyph,
                value: glyph,
                range: NSRange(location: metadata.location, length: metadata.length)
            )
        }

        reconstructedText = mutableAttrString

        print("\n" + String(repeating: "=", count: 60))
        print("✅ RECONSTRUCTION COMPLETE")
        print(String(repeating: "=", count: 60) + "\n")
    }
}

// MARK: - Database Model

struct GenmojiDatabaseModel: Identifiable {
    let id = UUID()
    let contentIdentifier: String
    let contentDescription: String
    let imageContent: Data
    let contentType: UTType
    let location: Int
    let length: Int

    // Codable version for Supabase
    struct Codable: Swift.Codable {
        let contentIdentifier: String
        let contentDescription: String
        let imageContent: Data
        let contentTypeIdentifier: String
        let location: Int
        let length: Int
    }

    var forSupabase: Codable {
        Codable(
            contentIdentifier: contentIdentifier,
            contentDescription: contentDescription,
            imageContent: imageContent,
            contentTypeIdentifier: contentType.identifier,
            location: location,
            length: length
        )
    }
}

// MARK: - Database Card View

struct DatabaseCard: View {
    let metadata: GenmojiDatabaseModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Preview
            HStack {
                if let image = UIImage(data: metadata.imageContent) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                }

                Text(metadata.contentDescription)
                    .font(.subheadline)
                    .bold()

                Spacer()
            }

            // Database fields
            VStack(alignment: .leading, spacing: 6) {
                DatabaseField(name: "content_identifier", value: metadata.contentIdentifier, type: "TEXT")
                DatabaseField(name: "content_description", value: metadata.contentDescription, type: "TEXT")
                DatabaseField(name: "image_content", value: "\(metadata.imageContent.count) bytes", type: "BYTEA")
                DatabaseField(name: "content_type", value: metadata.contentType.identifier, type: "TEXT")
                DatabaseField(name: "location", value: "\(metadata.location)", type: "INTEGER")
                DatabaseField(name: "length", value: "\(metadata.length)", type: "INTEGER")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct DatabaseField: View {
    let name: String
    let value: String
    let type: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(name)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 140, alignment: .leading)

            Text(value)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)

            Spacer()

            Text(type)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.blue)
        }
    }
}

// MARK: - Custom Text Editor (from article)

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: NSAttributedString?

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.allowsEditingTextAttributes = true
        textView.supportsAdaptiveImageGlyph = true
        textView.delegate = context.coordinator

        if let initialText = text {
            textView.attributedText = initialText
        }

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.attributedText != text {
            uiView.attributedText = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.attributedText
        }
    }
}

// MARK: - UILabel Rendering (from article pattern)

struct GenmojiLabel: UIViewRepresentable {
    let attributedText: NSAttributedString
    let fontSize: CGFloat

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)
        mutableAttrString.addAttribute(
            .font,
            value: UIFont.systemFont(ofSize: fontSize),
            range: NSRange(location: 0, length: 1)
        )

        uiView.attributedText = mutableAttrString
    }
}
