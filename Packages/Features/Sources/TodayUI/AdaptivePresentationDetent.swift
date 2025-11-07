import SwiftUI

struct AdaptiveExtraSmallDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.475 : maxHeight * 0.425
    }
}

struct AdaptiveSmallDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.5 : maxHeight * 0.425
    }
}

struct AdaptiveMediumDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.6 : maxHeight * 0.525
    }
}

public struct AdaptiveLargeDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.95 : maxHeight * 0.775
    }
}

public struct AdaptiveExtraLargeDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.975 : maxHeight * 0.825
    }
}
