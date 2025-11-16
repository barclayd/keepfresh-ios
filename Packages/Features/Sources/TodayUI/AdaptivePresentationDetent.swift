import SwiftUI

public struct AdaptiveExtraSmallDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.475 : maxHeight * 0.425
    }
}

public struct AdaptiveSmallDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.525 : maxHeight * 0.425
    }
}

public struct AdaptiveMediumDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.6 : maxHeight * 0.525
    }
}

public struct AdaptiveLargeDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.985 : maxHeight * 0.8
    }
}

public struct AdaptiveExtraLargeDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        return maxHeight < 700 ? maxHeight * 0.975 : maxHeight * 0.85
    }
}
