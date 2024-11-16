//
//  TodayView.swift
//  KeepFresh
//
//  Created by Dan Barclay on 13/11/2024.
//

import SwiftUI

let groceryItem: GroceryItem = .init(icon: "waterbottle", name: "Semi Skimmed Milk", category: "Dairy", brand: "Sainburys", amount: 4, unit: "pints", foodStore: .fridge, status: .open, wasteScore: 17, expiryDate: Date())

struct StatsView: View {
    var body: some View {
        HStack {
            VStack {
                Text("Location")
                    .textCase(.uppercase)
                    .foregroundColor(.gray400)
                    .font(.caption)
                Text(groceryItem.foodStore.rawValue)
                    .fontWeight(.bold)
                    .foregroundColor(.green600)
                    .font(.headline)
            }
            Spacer()

            VStack {
                Text("Status")
                    .textCase(.uppercase)
                    .foregroundColor(.gray400)
                    .font(.caption)
                Text(groceryItem.status.rawValue)
                    .fontWeight(.bold)
                    .foregroundColor(.green600)
                    .font(.headline)
            }
            Spacer()

            VStack {
                Text("Expiry")
                    .textCase(.uppercase)
                    .foregroundColor(.gray400)
                    .font(.caption)
                HStack(spacing: 3) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 18))
                        .foregroundColor(.green600)
                    Text("3 days")
                        .fontWeight(.bold)
                        .foregroundColor(.green600)
                        .font(.headline)
                }
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 20,
                bottomTrailingRadius: 20,
                topTrailingRadius: 0,
                style: .continuous
            )
        )
        .foregroundColor(.green300)
    }
}

struct WideStatsView: View {
    @State private var showFoodItemSheet = false

    var body: some View {
        HStack {
            VStack {
                Text("Location")
                    .textCase(.uppercase)
                    .foregroundColor(.gray400)
                    .font(.caption)
                Text(groceryItem.foodStore.rawValue)
                    .fontWeight(.bold)
                    .foregroundColor(.green600)
                    .font(.headline)
            }
            Spacer()

            VStack {
                Text("Status")
                    .textCase(.uppercase)
                    .foregroundColor(.gray400)
                    .font(.caption)
                Text(groceryItem.status.rawValue)
                    .fontWeight(.bold)
                    .foregroundColor(.green600)
                    .font(.headline)
            }
            Spacer()

            VStack {
                Text("Waste %")
                    .textCase(.uppercase)
                    .foregroundColor(.gray400)
                    .font(.caption)
                Text("\(String(format: "%.0f", groceryItem.amount))")
                    .fontWeight(.bold)
                    .foregroundColor(.green600)
                    .font(.headline)
            }
            Spacer()

            VStack {
                Text("EXPIRY")
                    .textCase(.uppercase)
                    .foregroundColor(.gray400)
                    .font(.caption)
                HStack(spacing: 3) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 18))
                        .foregroundColor(.green600)
                    Text("3 days")
                        .fontWeight(.bold)
                        .foregroundColor(.green600)
                        .font(.headline)
                }
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 20,
                bottomTrailingRadius: 20,
                topTrailingRadius: 0,
                style: .continuous
            )
        )
        .foregroundColor(.green300)
        .onTapGesture {
            showFoodItemSheet = true
        }
        .sheet(isPresented: $showFoodItemSheet) {
            Text("Food Item")
                .presentationDetents([.fraction(0.75)])
                .presentationDragIndicator(.visible)
        }
    }
}

struct TodayView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    Image(systemName: groceryItem.icon)
                        .font(.system(size: 36))
                    VStack(spacing: 5) {
                        Text(groceryItem.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            Text(groceryItem.category)
                                .font(.footnote)
                            Circle()
                                .frame(width: 4, height: 4)
                                .foregroundColor(.brandSainsburys)
                            Text(groceryItem.brand)
                                .font(.footnote)
                                .foregroundColor(.orange)
                            Circle()
                                .frame(width: 4, height: 4)
                                .foregroundColor(Color.black)
                            Text("\(String(format: "%.0f", groceryItem.amount)) \(groceryItem.unit)")
                                .font(.footnote)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background(Color.white)
                .cornerRadius(20)

                ViewThatFits {
                    WideStatsView()
                    StatsView()
                }
            }
            .padding(.bottom, 4)
            .padding(.horizontal, 4)
            .background(Color.white)
            .cornerRadius(20)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 10)
            .shadow(color: .shadow, radius: 2, x: 0, y: 4)
        }
        .background(Color("white-200"))
    }
}
