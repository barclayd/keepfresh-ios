import DesignSystem
import Environment
import Foundation
import Intelligence
import Models
import Network
import Router
import SwiftUI

@Observable
public class InventoryFormState {
    var expiryDate = Date()
    var expiryType: ExpiryType = .BestBefore
    var storageLocation: StorageLocation = .fridge
    var quantity = 1
    var status: ProductSearchItemStatus = .unopened
}

public struct AddInventoryItemView: View {
    @Environment(Inventory.self) var inventory
    @Environment(Router.self) var router

    @State private var item = InventoryItemSuggestions()
    @State private var formState = InventoryFormState()
    @State private var usageGenerator = UsageGenerator()

    public let productSearchItem: ProductSearchItemResponse

    public init(productSearchItem: ProductSearchItemResponse) {
        self.productSearchItem = productSearchItem
    }

    var isRecommendedExpiryDate: Bool {
        guard
            let recommendedNumberOfDays = item.suggestions?.shelfLifeInDays[formState.status][
                formState.storageLocation
            ]
        else {
            return false
        }
        return formState.expiryDate.isSameDay(as: addDaysToNow(recommendedNumberOfDays))
    }

    var isRecommendedStorageLocation: Bool {
        formState.storageLocation == item.suggestions?.recommendedStorageLocation
    }

    var calculatedExpiryDate: Date {
        guard
            let shelfLife = item.suggestions?.shelfLifeInDays,
            let expiry = getExpiryDateForSelection(
                storage: formState.storageLocation,
                status: formState.status,
                shelfLife: shelfLife)
        else {
            return Date()
        }
        return expiry
    }

    func addToInventory() async throws {
        print(
            "Expiry date: \(formState.expiryDate)",
            "Storage location: \(formState.storageLocation.rawValue)",
            "quantity: \(formState.quantity)",
            "status: \(formState.status.rawValue)")

        guard let recommendedExpiryType = item.suggestions?.expiryType,
              let recommendedStorageLocation = item.suggestions?.recommendedStorageLocation
        else {
            return
        }

        let request = AddInventoryItemRequest(
            item: AddInventoryItemRequest
                .InventoryItem(
                    expiryDate: formState.expiryDate,
                    storageLocation: formState
                        .storageLocation,
                    status: formState.status,
                    expiryType: formState
                        .expiryType,
                consumptionPrediction: usageGenerator.percentagePrediction),
            product: AddInventoryItemRequest
                .ProductData(
                    name: productSearchItem.name,
                    brand: productSearchItem
                        .brand,
                    expiryType: recommendedExpiryType,
                    storageLocation: recommendedStorageLocation,
                    barcode: productSearchItem
                        .source.ref,
                    unit: productSearchItem
                        .unit?.lowercased(),
                    amount: productSearchItem
                        .amount,
                    categoryId: productSearchItem
                        .category.id,
                    sourceId: productSearchItem
                        .source.id,
                    sourceRef: productSearchItem
                        .source.ref))

        let temporaryId = (inventory.items.max(by: { $0.id < $1.id })?.id ?? 0) + 1

        inventory.addItem(
            request: request,
            catgeory: productSearchItem.category,
            productId: temporaryId,
            imageURL: productSearchItem.imageURL)

        router.popToRoot(for: .search)
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    ZStack {
                        LinearGradient(stops: [
                            Gradient.Stop(color: .blue700, location: 0),
                            Gradient.Stop(color: .blue500, location: 0.2),
                            Gradient.Stop(color: .white200, location: 0.375),
                        ], startPoint: .top, endPoint: .bottom)
                            .ignoresSafeArea(edges: .top)
                            .offset(y: -geometry.safeAreaInsets.top)
                            .frame(height: geometry.size.height)
                            .frame(maxHeight: .infinity, alignment: .top)

                        VStack(spacing: 5) {
                            AsyncImage(url: productSearchItem.imageURL.flatMap(URL.init)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 150)
                            Text("\(productSearchItem.name)").font(.largeTitle).lineSpacing(0).foregroundStyle(
                                .blue700
                            ).fontWeight(.bold)
                            HStack {
                                Text(productSearchItem.category.name)
                                    .font(.callout).foregroundStyle(.gray600)
                                if let amount = productSearchItem.amount, let unit = productSearchItem.unit {
                                    Circle()
                                        .frame(width: 4, height: 4)
                                        .foregroundStyle(.gray600)

                                    Text("\(String(format: "%.0f", amount))\(unit)")
                                        .foregroundStyle(.gray600)
                                        .font(.callout)
                                }
                            }
                            Text(productSearchItem.brand)
                                .font(.headline).fontWeight(.bold)
                                .foregroundStyle(.brandSainsburys)

                            if item.isLoading {
                                ProgressView()
                            } else {
                                VStack {
                                    if let percentagePrediction = usageGenerator.percentagePrediction, usageGenerator.state != .loading {
                                        Text("\(percentagePrediction)%").font(.title).foregroundStyle(.yellow500).fontWeight(.bold)
                                            .lineSpacing(
                                                0)
                                    } else {
                                        ProgressView().controlSize(.regular).tint(.yellow500)
                                    }
                                    HStack(spacing: 0) {
                                        Text("Predicted usage").font(.subheadline).foregroundStyle(.black800)
                                            .fontWeight(.light)
                                        Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(
                                            .yellow500
                                        )
                                        .offset(x: -2, y: -10)
                                    }.offset(y: -5)
                                }.padding(.top, 10)

                                Grid {
                                    GridRow {
                                        Spacer()
                                        VStack(spacing: 0) {
                                            Text("32").fontWeight(.bold).font(.headline).foregroundStyle(.blue700)
                                            Text("Addded").fontWeight(.light).font(.subheadline).lineLimit(1)
                                                .foregroundStyle(.blue700)
                                        }
                                        Spacer()
                                        Image(systemName: "calendar.badge.plus")
                                            .font(.system(size: 32)).fontWeight(.bold)
                                            .foregroundStyle(.blue700)
                                        Spacer()
                                        VStack(spacing: 0) {
                                            Text("31").fontWeight(.bold).font(.headline).foregroundStyle(.blue700)
                                            Text("Consumed").fontWeight(.light).font(.subheadline).foregroundStyle(
                                                .blue700)
                                        }
                                        Spacer()
                                    }
                                    GridRow {
                                        Spacer()
                                        VStack(spacing: 0) {
                                            Text("2").fontWeight(.bold).font(.headline).foregroundStyle(.blue700)
                                                .foregroundStyle(.blue700)
                                            Text("In Fridge").fontWeight(.light).font(.subheadline)
                                                .foregroundStyle(.blue700)
                                        }
                                        Spacer()
                                        Image(systemName: "house")
                                            .font(.system(size: 32)).fontWeight(.bold)
                                            .foregroundStyle(.blue700)
                                        Spacer()
                                        VStack(spacing: 0) {
                                            Text("2").fontWeight(.bold).font(.headline).foregroundStyle(.blue700)
                                            Text("In Freezer").fontWeight(.light).font(.subheadline).foregroundStyle(
                                                .blue700)
                                        }
                                        Spacer()
                                    }
                                }.padding(.horizontal, 15).padding(.vertical, 5).frame(
                                    maxWidth: .infinity,
                                    alignment: .center)
                                    .background(.blue100)
                                    .cornerRadius(20)
                                    .padding(
                                        .bottom,
                                        10)

                                Grid(horizontalSpacing: 16, verticalSpacing: 20) {
                                    GridRow {
                                        Image(systemName: "checkmark.seal.fill").fontWeight(.bold)
                                            .foregroundStyle(.yellow500)
                                            .font(.system(size: 32))
                                        Text("Looks like a good choice, you’re unlikely to waste any of this item")
                                            .font(.callout)
                                            .foregroundStyle(.gray600)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2...2)

                                        Spacer()
                                    }
                                    GridRow {
                                        Image(systemName: "beach.umbrella.fill")
                                            .foregroundStyle(.blue600).fontWeight(.bold)
                                            .font(.system(size: 32))
                                        Text("You should only need to buy one of these before your next holiday")
                                            .font(.callout)
                                            .foregroundStyle(.gray600)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2...2)
                                        Spacer()
                                    }

                                }.padding(.vertical, 5).padding(.bottom, 10).padding(.horizontal, 20)

                                VStack(spacing: 15) {
                                    InventoryCategory(
                                        quantity: $formState.quantity,
                                        status: $formState.status,
                                        expiryDate: $formState.expiryDate,
                                        storageLocation: $formState.storageLocation,
                                        isRecommendedExpiryDate: isRecommendedExpiryDate,
                                        isRecommendedStorageLocation: isRecommendedStorageLocation,
                                        type: .Expiry)
                                    InventoryCategory(
                                        quantity: $formState.quantity,
                                        status: $formState.status,
                                        expiryDate: $formState.expiryDate,
                                        storageLocation: $formState.storageLocation,
                                        isRecommendedExpiryDate: isRecommendedExpiryDate,
                                        isRecommendedStorageLocation: isRecommendedStorageLocation,
                                        type: .Storage)
                                    InventoryCategory(
                                        quantity: $formState.quantity,
                                        status: $formState.status,
                                        expiryDate: $formState.expiryDate,
                                        storageLocation: $formState.storageLocation,
                                        isRecommendedExpiryDate: isRecommendedExpiryDate,
                                        isRecommendedStorageLocation: isRecommendedStorageLocation,
                                        type: .Status)
                                    InventoryCategory(
                                        quantity: $formState.quantity,
                                        status: $formState.status,
                                        expiryDate: $formState.expiryDate,
                                        storageLocation: $formState.storageLocation,
                                        isRecommendedExpiryDate: isRecommendedExpiryDate,
                                        isRecommendedStorageLocation: isRecommendedStorageLocation,
                                        type: .Quantity)
                                }
                            }
                        }
                        .padding(.bottom, 100)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: geometry.size.width)
                    }
                }.background(.white200)

                ZStack(alignment: .bottom) {
                    UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                        topLeading: 0,
                        bottomLeading: 40,
                        bottomTrailing: 40,
                        topTrailing: 0))
                        .fill(.white200)
                        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.25), radius: 4, x: 0, y: -4)
                        .frame(height: 80)

                    Button {
                        Task {
                            try await addToInventory()
                        }
                    } label: {
                        Text("Add to \(formState.storageLocation.rawValue.capitalized)")
                            .font(.title2)
                            .foregroundStyle(.blue600)
                            .fontWeight(.medium)
                            .padding()
                            .padding(.vertical, 20)
                    }
                }
            }
            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.bottom)
        .toolbarRole(.editor)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task.detached {
                        try await addToInventory()
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18))
                        .foregroundColor(.blue600)
                }
            }
        }
        .onAppear {
            Task {
                let previewProduct = InventoryPreviewRequest.PreviewProduct(
                    name: productSearchItem.name,
                    brand: productSearchItem.brand,
                    barcode: productSearchItem.source.ref,
                    unit: productSearchItem.unit,
                    amount: productSearchItem.amount,
                    categoryId: productSearchItem.category.id,
                    sourceId: productSearchItem.source.id,
                    sourceRef: productSearchItem.source.ref)
                await item.fetchInventorySuggestions(product: previewProduct)
            }
        }
        .onChange(of: item.suggestions) { _, newSuggestions in
            updateDefaultsFromSuggestions(newSuggestions)
        }
        .onChange(of: calculatedExpiryDate) { oldDate, newDate in
            if !newDate.isSameDay(as: oldDate) {
                formState.expiryDate = newDate
            }
        }
        .onChange(of: formState.expiryDate) { oldDate, newDate in
            if newDate.isSameDay(as: oldDate) {
                return
            }

            guard let predictions = item.predictions else {
                print("no predictions found for \(productSearchItem.name)")
                return
            }

            let quantityString: String? = {
                if let amount = productSearchItem.amount, let unit = productSearchItem.unit {
                    return "\(amount)\(unit)"
                }
                return nil
            }()

            Task {
                await usageGenerator.generateUsagePrediction(
                    predictions: predictions,
                    productName: productSearchItem.name,
                    categoryName: productSearchItem.category.name,
                    quantity: quantityString,
                    storageLocation: formState.storageLocation.rawValue,
                    daysUntilExpiry: newDate.timeUntil.totalDays,
                    status: formState.status.rawValue)
            }
        }
    }

    private func updateDefaultsFromSuggestions(_ suggestions: InventorySuggestionsResponse?) {
        guard let suggestions else { return }

        formState.storageLocation = suggestions.recommendedStorageLocation

        formState.expiryType = suggestions.expiryType
    }
}
