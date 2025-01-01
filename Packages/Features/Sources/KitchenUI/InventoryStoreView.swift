import DesignSystem
import Models
import Router
import SwiftUI

public struct InventoryStoreView: View {
    public let inventoryStore: InventoryStoreDetails

    public init(inventoryStore: InventoryStoreDetails) {
        self.inventoryStore = inventoryStore
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    ZStack {
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .blue700, location: 0),
                                Gradient.Stop(color: .blue500, location: 0.2),
                                Gradient.Stop(color: .white200, location: 0.375),
                            ], startPoint: .top, endPoint: .bottom
                        )
                        .ignoresSafeArea(edges: .top)
                        .offset(y: -geometry.safeAreaInsets.top)
                        .frame(height: geometry.size.height)
                        .frame(maxHeight: .infinity, alignment: .top)

                        VStack(spacing: 5) {
                            Image(systemName: inventoryStore.type.icon).font(.system(size: 78)).foregroundColor(
                                .white200)
                            Text(inventoryStore.name).font(.largeTitle).lineSpacing(0).foregroundStyle(
                                .blue800
                            ).fontWeight(.bold)

                            VStack {
                                Text("3%").font(.title).foregroundStyle(.yellow500).fontWeight(.bold).lineSpacing(0)
                                HStack(spacing: 0) {
                                    Text("Predicted waste score").font(.subheadline).foregroundStyle(.black800)
                                        .fontWeight(.light)
                                    Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.yellow500)
                                        .offset(x: -2, y: -10)
                                }.offset(y: -5)
                            }.padding(.top, 10)
                        }
                        .padding(.bottom, 100)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                    }
                }.background(.white200)
            }
            .frame(maxHeight: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.bottom)
        .toolbarRole(.editor)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "plus.app")
                        .font(.system(size: 18))
                        .foregroundColor(.white200)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 18))
                        .foregroundColor(.white200)
                }
            }
        }
    }
}
