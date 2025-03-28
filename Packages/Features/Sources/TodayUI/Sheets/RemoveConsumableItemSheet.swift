import SwiftUI

func calculatePredictedWastePercentageOffset(predictedWastePercentage: Double, sliderWidth: CGFloat) -> CGFloat {
    return (predictedWastePercentage / 100 - 0.5) * sliderWidth
}

public struct RemoveConsumableItemSheet: View {
    @State private var wastePercentage: Double = 0
    @State private var sliderWidth: CGFloat = 0

    let predictedWastePercentage: Double = 100

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            Text("How much Semi Skimmed Milk is left?").lineLimit(2).multilineTextAlignment(.center).fontWeight(.bold).padding(.horizontal, 20).font(.title2).padding(.top, 10)

            VStack(spacing: 0) {
                HStack(spacing: 30) {
                    EmptyView()
                        .frame(width: 20, alignment: .center)

                    Image(systemName: "sparkles")
                        .foregroundStyle(.yellow500)
                        .font(.system(size: 16)).offset(x: calculatePredictedWastePercentageOffset(predictedWastePercentage: predictedWastePercentage, sliderWidth: sliderWidth))

                    EmptyView()
                        .frame(width: 20, alignment: .center)
                }
                HStack(spacing: 30) {
                    Image(systemName: "trash.slash.fill")
                        .foregroundStyle(.green500)
                        .font(.system(size: 32))
                        .frame(width: 20, alignment: .center)

                    GeometryReader { geometry in
                        Slider(value: $wastePercentage, in: 0 ... 100).tint(.blue600).onAppear {
                            sliderWidth = geometry.frame(in: .local).width
                        }
                    }

                    Image(systemName: "trash.fill")
                        .foregroundStyle(.red500)
                        .font(.system(size: 32))
                        .frame(width: 20, alignment: .center)
                }
                Text("% waste").font(.callout).fontWeight(.light).foregroundStyle(.gray700).offset(y: -4)
            }

            Spacer()

            Button(action: {
                print("Mark as opened")
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "trash")
                        .font(.system(size: 18))
                        .frame(width: 20, alignment: .center)
                    Text("Discard with \(String(format: "%.0f", wastePercentage))% waste")
                        .font(.headline)
                }
                .foregroundStyle(.blue600)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.red200)
                )
            }
        }.frame(maxWidth: .infinity)
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
    }
}
