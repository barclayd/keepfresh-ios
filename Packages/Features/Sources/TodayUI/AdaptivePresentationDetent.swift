import SwiftUI

struct AdaptiveMediumDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.95 : maxHeight * 0.7
    }
}
