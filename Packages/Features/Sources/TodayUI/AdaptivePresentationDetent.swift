import SwiftUI

struct AdaptiveMediumDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.925 : maxHeight * 0.75
    }
}

struct AdaptiveMediumDetentLarge: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.975 : maxHeight * 0.8
    }
}
