//
//  Models.swift
//  BlockVaultApp
//
//  Created by Matt Norris on 3/18/24.
//

import Foundation
import SwiftUI

struct CryptoCoin: Identifiable, Hashable, Equatable {
    let id: Int
    let name: String
    let symbol: String
    let currentPrice: Double
    let priceChangePercentage24h: Double
    var historicalPrices: [(date: Date, price: Double)] = []
    
    init(id: Int, name: String, symbol: String, currentPrice: Double, priceChangePercentage24h: Double) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.currentPrice = currentPrice
        self.priceChangePercentage24h = priceChangePercentage24h
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(symbol)
        hasher.combine(currentPrice)
        hasher.combine(priceChangePercentage24h)
    }
    
    static func == (lhs: CryptoCoin, rhs: CryptoCoin) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.symbol == rhs.symbol &&
               lhs.currentPrice == rhs.currentPrice &&
               lhs.priceChangePercentage24h == rhs.priceChangePercentage24h &&
               lhs.historicalPrices.count == rhs.historicalPrices.count &&
               zip(lhs.historicalPrices, rhs.historicalPrices).allSatisfy({ $0.0.date == $0.1.date && $0.0.price == $0.1.price })
    }

}

struct Holding: Identifiable, Hashable {
    let id = UUID()
    var coin: CryptoCoin
    var holdingValue: Double
    
    var value: Double {
        return coin.currentPrice * holdingValue
    }
}

struct ColorTheme {
    var mainColor: Color
    var secondaryColor: Color
    var textColor: Color
    var backgroundColor: Color
    var coinSymbolColor: Color
    var placeholderColor: Color
    var buttonBackground: Color // new button background color

}

enum Theme {
    case dark
    case light
    
    var colorTheme: ColorTheme {
        switch self {
        case .dark:
            return ColorTheme(mainColor: Color(red: 0.149, green: 0.004, blue: 0.329), secondaryColor: Color(red: 1.0, green: 0.765, blue: 0.0), textColor: .white, backgroundColor: Color(red: 0.114, green: 0.114, blue: 0.114), coinSymbolColor: Color(red: 0.8, green: 0.8, blue: 0.8), placeholderColor: Color.gray, buttonBackground: Color(red: 0.2, green: 0.2, blue: 0.2)) // new button background color
        case .light:
            return ColorTheme(mainColor: Color(red: 0.9, green: 0.9, blue: 0.9), secondaryColor: Color(red: 0.2, green: 0.2, blue: 0.2), textColor: .black, backgroundColor: Color(red: 0.8, green: 0.8, blue: 0.8), coinSymbolColor: Color(red: 0.2, green: 0.2, blue: 0.2), placeholderColor: Color.gray, buttonBackground: Color(red: 0.8, green: 0.8, blue: 0.8)) // new button background color
        }
    }
}

let colorTheme: ColorTheme = Theme.dark.colorTheme // or .light
   
enum CoinType {
    case bitcoin
    case ethereum
    case ripple
    case litecoin
    case dogecoin
    
    var id: Int {
        switch self {
        case .bitcoin: return 1
        case .ethereum: return 2
        case .ripple: return 3
        case .litecoin: return 4
        case .dogecoin: return 5
        }
    }
    
    var name: String {
        switch self {
        case .bitcoin: return "Bitcoin"
        case .ethereum: return "Ethereum"
        case .ripple: return "Ripple"
        case .litecoin: return "Litecoin"
        case .dogecoin: return "Dogecoin"
        }
    }
    
    var symbol: String {
        switch self {
        case .bitcoin: return "btc"
        case .ethereum: return "eth"
        case .ripple: return "xrp"
        case .litecoin: return "ltc"
        case .dogecoin: return "doge"
        }
    }
    
    var currentPrice: Double {
        switch self {
        case .bitcoin: return 10000.0
        case .ethereum: return 3000.0
        case .ripple: return 1.0
        case .litecoin: return 200.0
        case .dogecoin: return 0.002
        }
    }
    
    var priceChangePercentage24h: Double {
        switch self {
        case .bitcoin: return 5.0
        case .ethereum: return -10.0
        case .ripple: return 2.0
        case .litecoin: return -8.0
        case .dogecoin: return 15.0
        }
    }
    
    
    func createCoin() -> CryptoCoin {
        var coin = CryptoCoin(id: self.id, name: self.name, symbol: self.symbol, currentPrice: self.currentPrice, priceChangePercentage24h: self.priceChangePercentage24h)
        coin.historicalPrices = []
        return coin
    }
}

let sampleCoins = [
    CoinType.bitcoin.createCoin(),
    CoinType.ethereum.createCoin(),
    CoinType.ripple.createCoin(),
    CoinType.litecoin.createCoin(),
    CoinType.dogecoin.createCoin(),
]

let sampleHoldings = [
    Holding(coin: sampleCoins[0], holdingValue: 0.2),
    Holding(coin: sampleCoins[1], holdingValue: 1.5),
    Holding(coin: sampleCoins[2], holdingValue: 1000.0),
    Holding(coin: sampleCoins[3], holdingValue: 2.0),
]

struct Transaction {
    let date: Date
    let description: String
    let amount: Double
    let price: Double
    let totalCost: Double
    let type: TransactionType
}

enum TransactionType {
    case buy
    case sell
}

class UserWallet: ObservableObject {
    static let shared = UserWallet(id: 1, accountName: "Main Account", walletID: "3HmNtzFuNGU8jDM6tY46h4uLnoFGgGqVP7", holdings: sampleHoldings, previousTotalValue: 4000.0, USDBalance: 10000.0)

    @Published var id: Int
    @Published var accountName: String
    @Published var walletID: String
    @Published var holdings: [Holding]
    @Published var previousTotalValue: Double
    @Published var USDBalance: Double
    @Published var transactionHistory: [Transaction] = []

    init(id: Int, accountName: String, walletID: String, holdings: [Holding], previousTotalValue: Double, USDBalance: Double) {
        self.id = id
        self.accountName = accountName
        self.walletID = walletID
        self.holdings = holdings
        self.previousTotalValue = previousTotalValue
        self.USDBalance = USDBalance
    }

    func calculateTotalValue() -> Double {
        return holdings.reduce(0.0, { $0 + $1.value })
    }

    func calculatePortfolioChangePercentage() -> Double {
        let totalValue = calculateTotalValue()
        let change = totalValue - previousTotalValue
        let percentageChange = (change / previousTotalValue) * 100
        return percentageChange
    }

    func calculatePortfolioChangeInUSD() -> Double {
        let totalValue = calculateTotalValue()
        let usdChange = abs(previousTotalValue - totalValue)
        return usdChange
    }

    func buyHoldingCrypto(holding: Holding, amount: Double, price: Double) {
        let totalCost = amount * price
        USDBalance -= totalCost
        if let index = holdings.firstIndex(where: { $0.coin.symbol == holding.coin.symbol }) {
            holdings[index].holdingValue += amount
        }
        previousTotalValue = calculateTotalValue()
        let transaction = Transaction(date: Date(), description: "Buy \(amount) \(holding.coin.symbol)", amount: amount, price: price, totalCost: totalCost, type: .buy)
        transactionHistory.append(transaction)
        print("Current USD Balance: \(USDBalance)")
    }

    func sellCrypto(totalSaleProfit: Double, amountsToSell: [CryptoCoin.ID: Double]) {
        USDBalance += totalSaleProfit
        for (coinID, amount) in amountsToSell {
            if let index = holdings.firstIndex(where: { $0.coin.id == coinID }) {
                let coin = holdings[index].coin
                let price = holdings[index].value
                let totalCost = amount * price
                holdings[index].holdingValue -= amount
                if holdings[index].holdingValue <= 0 {
                    holdings.remove(at: index)
                }
                let transaction = Transaction(date: Date(), description: "Sell \(amount) \(coin.symbol)", amount: amount, price: price, totalCost: totalCost, type: .sell)
                transactionHistory.append(transaction)
            }
        }
        previousTotalValue = calculateTotalValue()
        print("Current USD Balance: \(USDBalance)")
    }
}
