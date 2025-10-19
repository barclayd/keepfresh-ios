import CoreText
import Foundation

public class FontRegistration {
    public static func registerFonts() {
        guard let bundleURL = Bundle.module.url(forResource: "Shrikhand-Regular", withExtension: "ttf") else {
            return
        }

        CTFontManagerRegisterFontsForURL(bundleURL as CFURL, .process, nil)
    }
}
