import SwiftUI

public func formatCategoryPath(pathDisplay: String?) -> Text {
    guard let pathDisplay else { return Text("") }
    
    let parts = pathDisplay.split(separator: ".").dropFirst()
    var result = Text("")
    
    for (index, part) in parts.enumerated() {
        if index > 0 {
            result = Text("\(result) \(Image(systemName: "arrow.right"))")
        }
        result = Text("\(result)\(part)")
    }
    
    return result
}
