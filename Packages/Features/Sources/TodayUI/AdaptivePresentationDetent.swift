import SwiftUI

public struct AdaptiveExtraSmallDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue
        print("maxHeight: \(maxHeight) XS")

        return maxHeight < 700 ? maxHeight * 0.475 : maxHeight * 0.425
    }
}

public struct AdaptiveSmallDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue
        print("maxHeight: \(maxHeight) S")

        return maxHeight < 700 ? maxHeight * 0.525 : maxHeight * 0.425
    }
}

public struct AdaptiveMediumDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue
        print("maxHeight: \(maxHeight) M")

        return maxHeight < 700 ? maxHeight * 0.6 : maxHeight * 0.525
    }
}

public struct AdaptiveLargeDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue
        
        print("maxHeight: \(maxHeight) L")

        switch maxHeight {
            case ..<700:
                // iPhone SE, iPhone 8, etc.
                return maxHeight * 0.985

            case 700 ..< 800:
                // iPhone 13, 14, 15 (standard sizes)
                return maxHeight * 0.8

            case 800 ..< 900:
                // iPhone 14/15/16 Pro Max, Plus models (860)
                return maxHeight * 0.725

            case 900...:
                // iPhone 14/15/16 Pro Max, Plus models
                return maxHeight * 0.6

            default:
                return maxHeight * 0.6
        }
    }
}

public struct AdaptiveExtraLargeDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue
        
        print("maxHeight: \(maxHeight) XL")

        switch maxHeight {
            case ..<700:
                // iPhone SE, iPhone 8, etc.
                return maxHeight * 0.975

            case 700 ..< 800:
                // iPhone 13, 14, 15 (standard sizes)
                return maxHeight * 0.85

            case 800 ..< 900:
                // iPhone 14/15/16 Pro Max, Plus models (860)
                return maxHeight * 0.775

            case 900...:
                return maxHeight * 0.7

            default:
                return maxHeight * 0.7
        }
    }
}
