import Foundation

public final class SubBrandMapper: Sendable {
    public static let shared = SubBrandMapper()

    private let reverseMappings: [String: String]

    private init() {
        guard let url = Bundle.module.url(forResource: "sub-brands", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONDecoder().decode([String: [String]].self, from: data)
        else {
            reverseMappings = [:]
            return
        }

        var reverse: [String: String] = [:]
        for (parent, subBrands) in json {
            for subBrand in subBrands {
                reverse[subBrand.lowercased()] = parent.lowercased()
            }
        }
        reverseMappings = reverse
    }

    public func parentBrand(for brandName: String) -> String? {
        let lowercased = brandName.lowercased()

        if let parent = reverseMappings[lowercased] {
            return parent
        }

        for word in lowercased.split(separator: " ") {
            if let parent = reverseMappings[String(word)] {
                return parent
            }
        }

        return nil
    }
}
