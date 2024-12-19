import SwiftUI

public struct HeaderView: View {
  @Environment(\.dismiss) var dismiss
  let title: String
  let subtitle: String?
  let showBack: Bool

  public init(
    title: String,
    subtitle: String? = nil,
    showBack: Bool = true
  ) {
    self.title = title
    self.subtitle = subtitle
    self.showBack = showBack
  }

  public var body: some View {
    HStack {
      if showBack {
        Image(systemName: "chevron.backward")
          .id("back")
      }
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .lineLimit(1)
          .minimumScaleFactor(0.5)
        if let subtitle {
          Text(subtitle)
            .foregroundStyle(.secondary)
            .font(.callout)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
      }
    }
    .onTapGesture {
      dismiss()
    }
    .foregroundStyle(
      .primary.shadow(
        .inner(
          color: .shadowSecondary.opacity(0.5),
          radius: 1, x: -1, y: -1))
    )
    .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 1)
    .font(.title)
    .fontWeight(.bold)
    .listRowSeparator(.hidden)
  }
}
