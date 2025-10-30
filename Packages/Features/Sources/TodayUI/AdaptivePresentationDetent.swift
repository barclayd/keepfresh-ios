import SwiftUI

struct AdaptiveExtraSmallDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.45 : maxHeight * 0.4
    }
}

struct AdaptiveSmallDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.475 : maxHeight * 0.4
    }
}

struct AdaptiveMediumDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.925 : maxHeight * 0.75
    }
}

struct AdaptiveLargeDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.975 : maxHeight * 0.8
    }
}
