import DesignSystem
import Environment
import Extensions
import Foundation
import Intelligence
import Models
import Network
import Router
import SharedUI
import SwiftUI

@Observable
public class InventoryFormState {
    var expiryDate = Date()
    var expiryType: ExpiryType = .BestBefore
    var storageLocation: StorageLocation = .fridge
    var quantity = 1
    var status: ProductSearchItemStatus = .unopened
    var expiryOverridden: Overriden?
    var storageOverridden: Overriden?
    var statusOverridden: Overriden?
}

public struct AddInventoryItemView: View {
    @Environment(Inventory.self) var inventory
    @Environment(Router.self) var router
    
    @State private var preview = InventoryItemPreview()
    @State private var formState = InventoryFormState()
    @State private var usageGenerator = UsageGenerator()
    @State private var addItemSuccess = false
    
    public let productSearchItem: ProductSearchResultItemResponse
    
    public init(productSearchItem: ProductSearchResultItemResponse) {
        self.productSearchItem = productSearchItem
    }
    
    var isRecommendedExpiryDate: Bool {
        guard
            let recommendedNumberOfDays = preview.suggestions?.shelfLifeInDays[formState.status][
                formState.storageLocation
            ]
        else {
            return false
        }
        return formState.expiryDate.isSameDay(as: addDaysToNow(recommendedNumberOfDays))
    }
    
    var isRecommendedStorageLocation: Bool {
        formState.storageLocation == preview.suggestions?.recommendedStorageLocation
    }
    
    var calculatedExpiryDate: Date? {
        guard
            let shelfLife = preview.suggestions?.shelfLifeInDays,
            let expiry = getExpiryDateForSelection(
                storage: formState.storageLocation,
                status: formState.status,
                shelfLife: shelfLife)
        else {
            return nil
        }
        return expiry
    }
    
    func calculateExpiryDate(storageLocation: StorageLocation) -> Date? {
        guard
            let shelfLife = preview.suggestions?.shelfLifeInDays,
            let expiry = getExpiryDateForSelection(
                storage: storageLocation,
                status: formState.status,
                shelfLife: shelfLife)
        else {
            return nil
        }
        return expiry
    }
    
    func addToInventory() async throws {
        print(
            "Expiry date: \(formState.expiryDate)",
            "Storage location: \(formState.storageLocation.rawValue)",
            "quantity: \(formState.quantity)",
            "status: \(formState.status.rawValue)")
        
        let request = AddInventoryItemRequest(
            item: AddInventoryItemRequest
                .InventoryItem(
                    expiryDate: formState.expiryDate,
                    storageLocation: formState
                        .storageLocation,
                    status: formState.status,
                    expiryType: formState
                        .expiryType,
                    consumptionPrediction: usageGenerator.percentagePrediction,
                    consumptionPredictionChangedAt: usageGenerator.percentagePrediction != nil ? Date() : nil),
            productId: productSearchItem.id, quantity: formState.quantity)
        
        let temporaryInventoryItemId = (inventory.items.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        
        inventory.addItem(
            request: request,
            product: productSearchItem,
            category: productSearchItem.category,
            categorySuggestions: preview.suggestions,
            inventoryItemId: temporaryInventoryItemId,
            icon: productSearchItem.icon)
        
        addItemSuccess.toggle()
        router.popToRoot()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .bottom) {
                    VStack(spacing: 5) {
                        GenmojiView(name: productSearchItem.icon, fontSize: 98, tint: formState.storageLocation.foregroundColor)
                        
                        Text("\(productSearchItem.name)").font(.largeTitle).lineSpacing(0).foregroundStyle(
                            formState.storageLocation.foregroundColor
                        ).fontWeight(.bold).multilineTextAlignment(.center)
                        
                        HStack {
                            Text(productSearchItem.category.name)
                                .font(.callout)
                            if let amountFormatted = productSearchItem.amountUnitFormatted {
                                Circle()
                                    .frame(width: 4, height: 4)
                                
                                Text(amountFormatted)
                                    .font(.callout)
                            }
                        }.foregroundStyle(formState.storageLocation.infoColor)
                        
                        Text(productSearchItem.brand.name)
                            .font(.headline).fontWeight(.bold)
                            .foregroundStyle(formState.storageLocation == .freezer ? .blue400 : productSearchItem.brand.color)
                        
                        if usageGenerator.isAvailable {
                            VStack {
                                if let percentagePrediction = usageGenerator.percentagePrediction, usageGenerator.state != .loading {
                                    Text("\(percentagePrediction)%").font(.title).foregroundStyle(.yellow500).fontWeight(.bold)
                                        .lineSpacing(
                                            0)
                                } else {
                                    ProgressView().controlSize(.regular).tint(.yellow500)
                                }
                                
                                HStack(spacing: 0) {
                                    Text("Predicted usage").font(.subheadline).foregroundStyle(formState.storageLocation.foregroundColor)
                                        .fontWeight(.light)
                                    Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(
                                        .yellow500
                                    )
                                    .offset(x: -2, y: -10)
                                }.offset(y: -5)
                            }.padding(.top, 10)
                        }
                        
                        Grid {
                            GridRow {
                                Spacer()
                                VStack(spacing: 0) {
                                    Text("\(preview.predictions?.productHistory.purchaseCount ?? 0)").fontWeight(.bold)
                                        .font(.headline).foregroundStyle(.blue700)
                                    Text("Added").fontWeight(.light).font(.subheadline).lineLimit(1)
                                        .foregroundStyle(.blue700)
                                }
                                Spacer()
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 32)).fontWeight(.bold)
                                    .foregroundStyle(.blue700)
                                Spacer()
                                VStack(spacing: 0) {
                                    Text("\(preview.predictions?.productHistory.consumedCount ?? 0)").fontWeight(.bold)
                                        .font(.headline).foregroundStyle(.blue700)
                                    Text("Consumed").fontWeight(.light).font(.subheadline).foregroundStyle(
                                        .blue700)
                                }
                                Spacer()
                            }
                            
                            GridRow {
                                Spacer()
                                VStack(spacing: 0) {
                                    Text("\(inventory.productsByLocation[productSearchItem.id]?[.fridge]?.count ?? 0)").fontWeight(.bold)
                                        .font(.headline).foregroundStyle(.blue700)
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
                                    Text("\(inventory.productsByLocation[productSearchItem.id]?[.freezer]?.count ?? 0)").fontWeight(.bold)
                                        .font(.headline).foregroundStyle(.blue700)
                                    Text("In Freezer").fontWeight(.light).font(.subheadline).foregroundStyle(
                                        .blue700)
                                }
                                Spacer()
                            }
                            
                        }.padding(.horizontal, 15).padding(.vertical, 5).frame(
                            maxWidth: .infinity,
                            alignment: .center)
                            .glassEffect(.regular.tint(formState.storageLocation.statsBackgroundTint), in: .rect(cornerRadius: 20))
                            .cornerRadius(20)
                            .padding(
                                .bottom,
                                10)
                        
                        if let predictions = preview.predictions, let suggestions = preview.suggestions {
                            SuggestionsView(
                                storageLocation: formState.storageLocation,
                                predictions: predictions,
                                suggestions: suggestions,
                                itemName: productSearchItem.name.truncated(to: 20),
                                categoryName: productSearchItem.category.name.truncated(to: 18))
                        }
                        
                        VStack(spacing: 15) {
                            InventoryCategory(
                                type: .expiry(date: $formState.expiryDate, isRecommended: isRecommendedExpiryDate, overriden: $formState.expiryOverridden),
                                storageLocation: formState.storageLocation)
                            InventoryCategory(
                                type: .storage(location: $formState.storageLocation, isRecommended: isRecommendedStorageLocation, overriden: $formState.storageOverridden),
                                storageLocation: formState.storageLocation)
                            InventoryCategory(
                                type: .status(status: $formState.status, overriden: $formState.statusOverridden),
                                storageLocation: formState.storageLocation)
                            InventoryCategory(
                                type: .quantity(quantity: $formState.quantity),
                                storageLocation: formState.storageLocation)
                        }
                    }
                    .padding(.top, geometry.safeAreaInsets.top)
                    .padding(.bottom, 100)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: geometry.size.width)
                    .redactedShimmer(when: preview.isLoading)
                }
                .background {
                    LinearGradient(stops: formState.storageLocation.viewGradientStops, startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea(.all)
                }
            }
            .overlay(alignment: .bottom) {
                BottomActionButton(
                    title: "Add to \(formState.storageLocation.rawValue.capitalized)",
                    safeAreaInsets: geometry.safeAreaInsets,
                    action: addToInventory)
            }
            .edgesIgnoringSafeArea(.top)
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
        .sensoryFeedback(.success, trigger: addItemSuccess)
        .task {
            usageGenerator.prewarmModel()
        }
        .onAppear {
            Task {
                await preview.fetchInventorySuggestions(categoryId: productSearchItem.category.id, productId: productSearchItem.id)
            }
        }
        .onChange(of: preview.suggestions) { _, newSuggestions in
            updateDefaultsFromSuggestions(newSuggestions)
        }
        .onChange(of: formState.status) { _, newStatus in
            if let calculatedExpiryDate, formState.expiryOverridden != .user {
                formState.expiryDate = calculatedExpiryDate
            }
            guard formState.storageOverridden != .user, let storageOptions = preview.suggestions?.shelfLifeInDays[newStatus] else {
                return
            }
            
            let preferredOrder: [StorageLocation] = [.pantry, .fridge, .freezer]
            if let firstAvailableLocation = preferredOrder.first(where: { storageOptions[$0] != nil }) {
                formState.storageLocation = firstAvailableLocation
            }
        }
        .onChange(of: formState.storageLocation) { _, newStorageLocation in
            if formState.expiryOverridden != .user, let newExpiryDate = calculateExpiryDate(storageLocation: newStorageLocation) {
                formState.expiryDate = calculatedExpiryDate
            }
        }
        .onChange(of: formState.expiryDate) { oldDate, newDate in
            guard !newDate.isSameDay(as: oldDate) else { return }
            guard let predictions = preview.predictions else {
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
        
        if let calculatedExpiryDate {
            formState.expiryDate = calculatedExpiryDate
        }
    }
}
