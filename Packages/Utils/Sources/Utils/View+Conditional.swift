import SwiftUI

public extension View {
    /// Applies a modifier only if the condition is true.
    ///
    /// - Parameters:
    ///   - condition: A boolean expression that determines if the modifier should be applied.
    ///     Uses `@autoclosure` so you can pass expressions directly without wrapping in `{ }`.
    ///   - modifier: The modifier to apply when the condition is met
    /// - Returns: The view with the modifier applied conditionally
    ///
    /// Example:
    /// ```swift
    /// Text("Hello")
    ///     .conditional(if: OSVersion.iOS(26)) { view in
    ///         view.fontWeight(.semibold)
    ///     }
    /// ```
    @ViewBuilder
    func conditional<Content: View>(
        if condition: @autoclosure () -> Bool,
        @ViewBuilder apply modifier: (Self) -> Content
    ) -> some View {
        if condition() {
            modifier(self)
        } else {
            self
        }
    }

    /// Applies a modifier with a fallback for when the condition is false.
    ///
    /// - Parameters:
    ///   - condition: A closure that returns true if the primary modifier should be applied
    ///   - primary: The modifier to apply when the condition is met
    ///   - fallback: The fallback modifier to apply when the condition is not met
    /// - Returns: The view with either the primary or fallback modifier applied
    ///
    /// Example:
    /// ```swift
    /// Text("Hello")
    ///     .conditional(
    ///         if: { OSVersion.iOS(26) },
    ///         apply: { $0.glassEffect() },
    ///         otherwise: { $0.background(.regularMaterial) }
    ///     )
    /// ```
    @ViewBuilder
    func conditional<PrimaryContent: View, FallbackContent: View>(
        if condition: () -> Bool,
        apply primary: (Self) -> PrimaryContent,
        otherwise fallback: (Self) -> FallbackContent
    ) -> some View {
        if condition() {
            primary(self)
        } else {
            fallback(self)
        }
    }

    /// Applies modifiers with full control over availability checks.
    ///
    /// This version passes the view to a closure where you can perform your own
    /// `if #available` checks and apply different modifiers accordingly.
    ///
    /// - Parameter modifier: A closure that receives the view and can apply conditional modifiers
    /// - Returns: The view with conditional applied modifiers
    ///
    /// Example:
    /// ```swift
    /// Text("Hello")
    ///     .conditional { view in
    ///         if #available(iOS 26.0, *) {
    ///             view.glassEffect()
    ///         } else {
    ///             view.background(.regularMaterial)
    ///         }
    ///     }
    /// ```
    @ViewBuilder
    func conditional<Content: View>(
        @ViewBuilder apply modifier: (Self) -> Content
    ) -> some View {
        modifier(self)
    }

    /// Applies a modifier if the provided optional value is non-nil.
    ///
    /// This variant automatically unwraps an optional value and passes it to the modifier closure,
    /// allowing you to apply modifiers based on optional data without manual unwrapping.
    ///
    /// - Parameters:
    ///   - optional: An optional value that determines if the modifier should be applied
    ///   - modifier: A closure that receives the view and unwrapped value when the optional is non-nil
    /// - Returns: The view with the modifier applied if the optional is non-nil, otherwise the original view
    ///
    /// Example:
    /// ```swift
    /// Text("Hello")
    ///     .conditional(if: optionalColor) { view, color in
    ///         view.foregroundStyle(color)
    ///     }
    /// ```
    @ViewBuilder
    func conditional<Content: View, Value>(
        if optional: Value?,
        @ViewBuilder apply modifier: (Self, Value) -> Content
    ) -> some View {
        if let value = optional {
            modifier(self, value)
        } else {
            self
        }
    }

    /// Applies a modifier only if the condition is false.
    ///
    /// This is the negated variant of `conditional(if:apply:)`. Sometimes `unless` reads
    /// better than `if: !condition`, making your code more semantic and easier to understand.
    ///
    /// - Parameters:
    ///   - condition: A boolean expression that determines if the modifier should NOT be applied.
    ///     Uses `@autoclosure` so you can pass expressions directly without wrapping in `{ }`.
    ///   - modifier: The modifier to apply when the condition is false
    /// - Returns: The view with the modifier applied when the condition is false, otherwise the original view
    ///
    /// Example:
    /// ```swift
    /// Text("Content")
    ///     .conditional(unless: isCompact) { view in
    ///         view.padding(.horizontal, 40)
    ///     }
    /// ```
    @ViewBuilder
    func conditional<Content: View>(
        unless condition: @autoclosure () -> Bool,
        @ViewBuilder apply modifier: (Self) -> Content
    ) -> some View {
        if !condition() {
            modifier(self)
        } else {
            self
        }
    }
}
