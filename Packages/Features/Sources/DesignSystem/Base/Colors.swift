import SwiftUI
import UIKit

public extension ShapeStyle where Self == Color {
    static var white200: Color {
        Color("white-200", bundle: .module)
    }

    static var white300: Color {
        Color("white-300", bundle: .module)
    }

    static var white400: Color {
        Color("white-400", bundle: .module)
    }

    static var black800: Color {
        Color("black-800", bundle: .module)
    }

    static var blue100: Color {
        Color("blue-100", bundle: .module)
    }

    static var blue200: Color {
        Color("blue-200", bundle: .module)
    }

    static var blue400: Color {
        Color("blue-400", bundle: .module)
    }

    static var blue500: Color {
        Color("blue-500", bundle: .module)
    }

    static var blue600: Color {
        Color("blue-600", bundle: .module)
    }

    static var blue700: Color {
        Color("blue-700", bundle: .module)
    }

    static var blue800: Color {
        Color("blue-800", bundle: .module)
    }

    static var brandSainsburys: Color {
        Color("brand-sainsburys", bundle: .module)
    }

    static var yellow500: Color {
        Color("yellow-500", bundle: .module)
    }

    static var gray100: Color {
        Color("gray-100", bundle: .module)
    }

    static var gray150: Color {
        Color("gray-150", bundle: .module)
    }

    static var gray200: Color {
        Color("gray-200", bundle: .module)
    }

    static var gray400: Color {
        Color("gray-400", bundle: .module)
    }

    static var gray500: Color {
        Color("gray-500", bundle: .module)
    }

    static var gray600: Color {
        Color("gray-600", bundle: .module)
    }

    static var green300: Color {
        Color("green-300", bundle: .module)
    }

    static var green500: Color {
        Color("green-500", bundle: .module)
    }

    static var green600: Color {
        Color("green-600", bundle: .module)
    }

    static var red200: Color {
        Color("red-200", bundle: .module)
    }

    static var shadow: Color {
        Color("shadow", bundle: .module)
    }
}

public extension UIColor {
    static var white200: UIColor {
        UIColor(named: "white-200", in: .module, compatibleWith: nil) ?? .white
    }

    static var white400: UIColor {
        UIColor(named: "white-400", in: .module, compatibleWith: nil) ?? .white
    }

    static var gray150: UIColor {
        UIColor(named: "gray-150", in: .module, compatibleWith: nil) ?? .gray
    }

    static var gray200: UIColor {
        UIColor(named: "gray-200", in: .module, compatibleWith: nil) ?? .gray
    }

    static var blue400: UIColor {
        UIColor(named: "blue-400", in: .module, compatibleWith: nil) ?? .blue
    }

    static var blue600: UIColor {
        UIColor(named: "blue-600", in: .module, compatibleWith: nil) ?? .blue
    }
    
    static var blue800: UIColor {
        UIColor(named: "blue-800", in: .module, compatibleWith: nil) ?? .blue
    }
}
