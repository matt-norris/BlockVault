//
//  Dashboard.swift
//  BlockVaultApp
//
//  Created by Matt Norris on 3/18/24.
//

import Foundation
import SwiftUI

struct WalletCardView: View {
    @ObservedObject var userWallet = UserWallet.shared
    let colorTheme: ColorTheme
    @State private var isAssetAllocationViewPresented = false

    var body: some View {
        VStack(spacing: 30) {
            HStack {
                WalletDetailView(
                    title: "Account Name",
                    detail: userWallet.accountName,
                    colorTheme: colorTheme
                )
                WalletDetailView(
                    title: "Wallet ID",
                    detail: userWallet.walletID,
                    colorTheme: colorTheme
                )
            }
            HStack {
                WalletTotalValueView(
                    totalValue: userWallet.calculateTotalValue(),
                    colorTheme: colorTheme
                )
                WalletDetailView(
                    title: "Portfolio Change (24h)",
                    detail: String(userWallet.calculatePortfolioChangeInUSD()),
                    colorTheme: colorTheme
                )
            }
            Button(action: {
                isAssetAllocationViewPresented = true
            }) {
                Text("View Asset Allocation")
            }
            .sheet(isPresented: $isAssetAllocationViewPresented) {
                AssetAllocationView(userWallet: userWallet)
            }
        }
        .padding()
    }
}

struct DetailedCellView: View {
    let holding: Holding
    
    var body: some View {
        VStack {
            Text("Symbol: \(holding.coin.symbol)")
            Text("Current Price: $\(String(format: "%.2f", holding.coin.currentPrice))")
            Text("Price Change 24h: \(String(format: "%.2f%%", holding.coin.priceChangePercentage24h))")
            LineGraph(data: holding.coin.historicalPrices)
            ForEach(holding.coin.historicalPrices, id: \.date) { historicalPrice in
                Text("Price on \(dateFormatter(date: historicalPrice.date)): $\(String(format: "%.2f", historicalPrice.price))")
                    .foregroundColor(historicalPrice.price > holding.coin.currentPrice ? .green : .red)
            }
        }
        .padding()
    }
    
    func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}

struct LineGraph: View {
    let data: [(date: Date, price: Double)]
    
    var body: some View {
        GeometryReader { geometry in
            let minPrice = data.map { $0.price }.min()!
            let maxPrice = data.map { $0.price }.max()!
            let priceRange = maxPrice - minPrice
            let graphHeight = geometry.size.height
            
            VStack {
                Text("Price History")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                    .offset(y: -20)
                
                Path { path in
                    for (i, point) in data.enumerated() {
                        if i == 0 {
                            path.move(to: CGPoint(x: 0, y: graphHeight - (graphHeight * ((point.price - minPrice) / priceRange))))
                        } else {
                            _ = data[i - 1]
                            let x = CGFloat(i) / CGFloat(data.count) * geometry.size.width
                            let y = graphHeight - (graphHeight * ((point.price - minPrice) / priceRange))
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 2)
                .frame(width: geometry.size.width, height: geometry.size.height)
                
                ZStack {
                    ForEach(Array(data.enumerated()), id: \.element.date) { (i, point) in
                        Circle()
                            .frame(width: 5, height: 5)
                            .position(x: geometry.size.width * CGFloat(i) / CGFloat(data.count), y: graphHeight - (graphHeight * ((point.price - minPrice) / priceRange)))
                    }
                }

                }
            }
        }
}

struct AssetAllocationView: View {
    @ObservedObject var userWallet = UserWallet.shared
   
   var body: some View {
       VStack {
           ForEach(userWallet.holdings) { holding in
               DisclosureGroup(holding.coin.name) {
                   DetailedCellView(holding: holding)
                       .animation(.easeInOut(duration: 0.5), value: 1.2)
               }
               
           }
       }
       .padding()
       .background(Color.white)
       .cornerRadius(10)
       .shadow(radius: 10)
   }
}

struct WalletOverviewView: View {
    @ObservedObject var userWallet = UserWallet.shared
    let colorTheme: ColorTheme

    var body: some View {
        ZStack {
            BlurView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                .cornerRadius(40)
                .padding()
            WalletCardView(userWallet: userWallet, colorTheme: colorTheme)
        }
    }
}

struct WalletDetailView: View {
    let title: String
    let detail: String
    let colorTheme: ColorTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(colorTheme.textColor)
            Text(detail)
                .font(.subheadline)
                .foregroundColor(colorTheme.textColor)
        }
        .padding()
    }
}

struct WalletTotalValueView: View {
    @State private var hideTotalValue = false
    @State private var displayInBitcoin = false
    let totalValue: Double
    let colorTheme: ColorTheme
    let bitcoinPrice: Double = 10000
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Total Value:")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(colorTheme.textColor)
            if hideTotalValue {
                Text("******")
                    .font(.subheadline)
                    .foregroundColor(colorTheme.textColor)
            } else {
                if displayInBitcoin {
                    Text(String(format: "%.2f", totalValue / bitcoinPrice))
                        .font(.subheadline)
                        .foregroundColor(Color(#colorLiteral(red: 0.992156862745098, green: 0.588235294117647, blue: 0.0627450980392157, alpha: 1)))
                } else {
                    Text("$\(String(format: "%.2f", totalValue))")
                        .font(.subheadline)
                        .foregroundColor(colorTheme.textColor)
                }
            }
            Button(action: {
                self.hideTotalValue.toggle()
            }) {
                Image(systemName: "eye.slash")
                    .font(.title)
                    .foregroundColor(colorTheme.textColor)
            }
            .padding()
            Toggle(isOn: $displayInBitcoin) {
                Text("Display in Bitcoin")
            }
            .padding()
        }
        .padding()
    }
}

struct DashboardView: View {
    @ObservedObject var userWallet = UserWallet.shared
    let colorTheme: ColorTheme
    @State private var searchText = ""
    
    
    var body: some View {
        
            ZStack {
                VStack {
                    NavigationBarView(colorTheme: colorTheme, searchText: $searchText)
                    ScrollView{
                        WalletOverviewView(userWallet: userWallet, colorTheme: colorTheme)
                        WalletActionButtonView(colorTheme: colorTheme, userWallet: userWallet)
                        CryptoListView(userWallet: userWallet, colorTheme: colorTheme)
                    }
                }
            }
            
            .background(colorTheme.mainColor) // Set the background
        
    }
}


struct NavigationBarView: View {
    let colorTheme: ColorTheme
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 8)

            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 8)

            Spacer()

            Image(systemName: "bell.fill")
                .foregroundColor(.gray)
                .padding(.trailing, 8)
        }
        .background(colorTheme.mainColor)
        .padding(.vertical, 10)
    }
}

struct CryptoCellView: View {
    @ObservedObject var userWallet = UserWallet.shared
    let colorTheme: ColorTheme
    let holding: Holding
    var body: some View {
        HStack {
            Image(uiImage: getImage(symbol: holding.coin.symbol))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(holding.coin.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                
                Text("Price: \(holding.coin.currentPrice)")
                    .font(.body)
                    .foregroundColor(Color.gray)
                
                Text("Holding Value: \(holding.holdingValue)")
                    .font(.body)
                    .foregroundColor(Color.gray)
            }
            .padding()
            
            Text("Price Change (24h): \(holding.coin.priceChangePercentage24h.formattedWithSign())%")
                .font(.body)
                .foregroundColor(holding.coin.priceChangePercentage24h >= 0 ? .green : .red)
            
            Spacer()
        }
        .padding()
        .background(BlurView(effect: UIBlurEffect(style: .systemMaterial)))
        .cornerRadius(10)
    }
    
    func getImage(symbol: String) -> UIImage {
        if let image = UIImage(named: symbol) {
            return image
        } else {
            return UIImage(systemName: "circle")!
        }
    }
}

struct GradientButtonModifier: ViewModifier {
    let colorTheme: ColorTheme
    
    func body(content: Content) -> some View {
        content
            .background(LinearGradient(gradient: Gradient(colors: [colorTheme.mainColor, colorTheme.secondaryColor]), startPoint: .top, endPoint: .bottom))
            .cornerRadius(20)
    }
}

extension View {
    func gradientButton(colorTheme: ColorTheme) -> some View {
        self.modifier(GradientButtonModifier(colorTheme: colorTheme))
    }
}

struct FilterMenu: View {
    @Binding var selectedSortingOption: Int
    @State private var isPressed = false
    @State private var isDropdownOpen = false
    
    let colorTheme: ColorTheme = Theme.dark.colorTheme
    
    var body: some View {
        HStack {
            Text("Sort and Filter")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Button {
                // New feature: Reset all filters
                selectedSortingOption = 0
                withAnimation {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        isPressed = false
                    }
                }
            } label: {
                Text("Reset Filters")
            }
            .padding()
            .gradientButton(colorTheme: colorTheme)
            .scaleEffect(isPressed ? 0.5 : 1.0)
            
            Button {
                withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0)) {
                    isDropdownOpen.toggle()
                }
            } label: {
                Text("Sort by")
            }
            .padding()
            .gradientButton(colorTheme: colorTheme)
            
            if isDropdownOpen {
                VStack {
                    Button {
                        selectedSortingOption = 0
                        isDropdownOpen = false
                    } label: {
                        Text("Name")
                    }
                    .padding()
                    Button {
                        selectedSortingOption = 1
                        isDropdownOpen = false
                    } label: {
                        Text("Price")
                    }
                    .padding()
                    Button {
                        selectedSortingOption = 2
                        isDropdownOpen = false
                    } label: {
                        Text("Holding Value")
                    }
                    .padding()
                }
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                .padding()
            }
        }
    }
}

struct CryptoListView: View {
    @ObservedObject var userWallet = UserWallet.shared
    let colorTheme: ColorTheme
    @State private var selectedSortingOption = 0
    
    var body: some View {
        ScrollView {
            VStack {
                FilterMenu(selectedSortingOption: $selectedSortingOption)
                ForEach(userWallet.holdings.sorted(by: {
                    switch selectedSortingOption {
                    case 0: return $0.coin.name < $1.coin.name
                    case 1: return $0.coin.currentPrice < $1.coin.currentPrice
                    case 2: return $0.holdingValue < $1.holdingValue
                    default: return false
                    }
                }), id: \.id) { holding in
                    CryptoCellView(userWallet: userWallet, colorTheme: colorTheme, holding: holding)
                }
            }
        }
    }
}

extension Double {
    func formattedWithSign() -> String {
        return self >= 0 ? "+\(self.formatted)" : "\(self.formatted)"
    }
}

extension Double {
    var formatted: String {
        return String(format: "%.\(2)f", self)
    }
}

struct BlurView: UIViewRepresentable {
    var effect: UIVisualEffect
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}

struct CopyButtonView: View {
    let walletID: String
    @State private var isCopied = false
    @State private var displayedID: String = ""
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            HStack {
                Text(displayedID)
                    .font(.body)
                    .foregroundColor(.primary)
                
                CopySymbolView(isCopied: $isCopied, walletID: walletID)
            }
            if isCopied {
                Text("Copied to Keyboard")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onReceive(timer) { _ in
            isCopied = false
        }
        .onAppear {
            displayedID = getDisplayedID()
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    private func getDisplayedID() -> String {
        guard walletID.count > 6 else {
            return walletID
        }
        
        let firstThree = String(walletID.prefix(3))
        let lastThree = String(walletID.suffix(3))
        let middle = String(repeating: "*", count: 4)
        
        return firstThree + middle + lastThree
    }
}

struct CopySymbolView: View {
    @Binding var isCopied: Bool
    let walletID: String
    
    var body: some View {
        Image(systemName: isCopied ? "doc.on.doc.fill" : "doc.on.doc")
            .font(.body)
            .foregroundColor(.primary)
            .background(Color(red: 0.25, green: 0, blue: 1, opacity: 1))
            .cornerRadius(5)
            .onTapGesture {
                saveToClipboard(text: walletID)
                isCopied = true
            }
    }
    
    private func saveToClipboard(text: String) {
        UIPasteboard.general.string = text
    }
}
