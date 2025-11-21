import SwiftUI

public struct AdaptiveExtraSmallDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue
        print("maxHeight: \(maxHeight) XS")

        switch maxHeight {
        case ..<700:
            // iPhone SE, iPhone 8, etc.
            return maxHeight * 0.4

        case 700 ..< 800:
            // iPhone 13, 14, 15
            return maxHeight * 0.3

        case 800 ..< 900:
            // iPhone 14/15/16 Pro Max, Plus models
            return maxHeight * 0.275

        case 900...:
            // iPhone 14/15/16 Pro Max, Plus models
            return maxHeight * 0.375

        default:
            return maxHeight * 0.375
        }
    }
}

public struct AdaptiveSmallDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue
        print("maxHeight: \(maxHeight) S")

        switch maxHeight {
        case ..<700:
            // iPhone SE, iPhone 8, etc.
            return maxHeight * 0.45

        case 700 ..< 800:
            // iPhone 13, 14, 15
            return maxHeight * 0.375

        case 800 ..< 900:
            // iPhone 14/15/16 Pro Max, Plus models
            return maxHeight * 0.35

        case 900...:
            return maxHeight * 0.375

        default:
            return maxHeight * 0.375
        }
    }
}

public struct AdaptiveMediumDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue
        print("maxHeight: \(maxHeight) M")

        switch maxHeight {
        case ..<700:
            // iPhone SE, iPhone 8, etc.
            return maxHeight * 0.7

        case 700 ..< 800:
            // iPhone 13, 14, 15
            return maxHeight * 0.55

        case 800 ..< 900:
            // iPhone 14/15/16 Pro Max, Plus models (860)
            return maxHeight * 0.5

        case 900...:
            // iPhone 14/15/16 Pro Max, Plus models
            return maxHeight * 0.5

        default:
            return maxHeight * 0.5
        }

//        return maxHeight < 700 ? maxHeight * 0.6 : maxHeight * 0.525
    }
}

public struct AdaptiveLargeDetent: CustomPresentationDetent {
    public static func height(in context: Context) -> CGFloat? {
        let maxHeight = context.maxDetentValue

        print("maxHeight: \(maxHeight) L")

        switch maxHeight {
        case ..<700:
            // iPhone SE, iPhone 8
            return maxHeight * 0.985

        case 700 ..< 800:
            // iPhone 13, 14, 15
            return maxHeight * 0.8

        case 800 ..< 900:
            // iPhone 14/15/16 Pro Max, Plus models
            return maxHeight * 0.725

        case 900...:
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
            return maxHeight

        case 700 ..< 800:
            // iPhone 13, 14, 15
            return maxHeight * 0.85

        case 800 ..< 900:
            // iPhone 14/15/16 Pro Max, Plus models
            return maxHeight * 0.775

        case 900...:
            return maxHeight * 0.7

        default:
            return maxHeight * 0.7
        }
    }
}
