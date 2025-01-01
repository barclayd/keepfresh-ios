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
                            stops: inventoryStore.type.viewGradientStops, startPoint: .top, endPoint: .bottom
                        )
                        .ignoresSafeArea(edges: .top)
                        .offset(y: -geometry.safeAreaInsets.top)
                        .frame(height: geometry.size.height)
                        .frame(maxHeight: .infinity, alignment: .top)

                        VStack(spacing: 15) {
                            Image(systemName: inventoryStore.type.icon).font(.system(size: 78)).foregroundColor(
                                .blue700)
                            Text(inventoryStore.name).font(.largeTitle).lineSpacing(0).foregroundStyle(
                                .blue700
                            ).fontWeight(.bold)

                            VStack {
                                Text("3%").font(.title).foregroundStyle(.yellow500).fontWeight(.bold).lineSpacing(0)
                                HStack(spacing: 0) {
                                    Text("Predicted waste score").font(.subheadline).foregroundStyle(.black800)
                                        .fontWeight(.light)
                                    Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.yellow500)
                                        .offset(x: -2, y: -10)
                                }.offset(y: -5)
                            }

                            Grid(horizontalSpacing: 30, verticalSpacing: 10) {
                                GridRow {
                                    VStack(spacing: 0) {
                                        Text("3").foregroundStyle(.green600).fontWeight(.bold).font(.headline)
                                        Text("Expriing soon").foregroundStyle(.green600).fontWeight(.light).font(.subheadline).lineLimit(1)
                                    }
                                    Image(systemName: "hourglass")
                                        .font(.system(size: 28)).fontWeight(.bold)
                                        .foregroundStyle(.blue700)
                                    Image(systemName: "clock.badge.exclamationmark")
                                        .font(.system(size: 28)).fontWeight(.bold)
                                        .foregroundStyle(.blue700)
                                    VStack(spacing: 0) {
                                        Text("1").fontWeight(.bold).font(.headline).foregroundStyle(.blue700)
                                        Text("Expires today").fontWeight(.light).font(.subheadline).foregroundStyle(.blue700)
                                    }
                                }
                                GridRow {
                                    VStack(spacing: 0) {
                                        Text("32").foregroundStyle(.blue700).fontWeight(.bold).font(.headline)
                                        Text("Recently added").foregroundStyle(.blue700).fontWeight(.light).font(.subheadline).lineLimit(1)
                                    }
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.system(size: 28)).fontWeight(.bold)
                                        .foregroundStyle(.blue700)
                                    Image(systemName: "list.number")
                                        .font(.system(size: 28)).fontWeight(.bold)
                                        .foregroundStyle(.blue700)
                                    VStack(spacing: 0) {
                                        Text("34").fontWeight(.bold).font(.headline).foregroundStyle(.blue700)
                                        Text("Total items").fontWeight(.light).font(.subheadline).foregroundStyle(.blue700)
                                    }
                                }
                            }.padding(.horizontal, 15).padding(.vertical, 5).frame(maxWidth: .infinity, alignment: .center).background(.blue150).cornerRadius(20)
                            
                            HStack {
                                Text("Recently added").font(.title).foregroundStyle(.blue700).fontWeight(.bold)
                                Spacer()
                            }

                            Spacer()
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
                        .foregroundColor(.white200).fontWeight(.bold)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 18))
                        .foregroundColor(.white200).fontWeight(.bold)
                }
            }
        }
    }
}
