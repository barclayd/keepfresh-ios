import SwiftUI

public func formatCategoryPath(pathDisplay: String?) -> Text {
    guard let pathDisplay else { return Text("") }

    let parts = Array(pathDisplay.split(separator: ".").dropFirst().reversed())

    var result = Text("")

    for (index, part) in parts.enumerated() {
        let text = Text(String(part))
            .font(index == 0 ? .body : .caption)

        if index > 0 {
            result = Text("\(result)\n\(text)")
        } else {
            result = text
        }
    }

    return result
}
