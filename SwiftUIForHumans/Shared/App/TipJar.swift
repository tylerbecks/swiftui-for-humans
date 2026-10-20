import StoreKit
import SwiftUI

/// Tips are consumable in-app purchases (App Review 3.1.1: "Apps may use
/// in-app purchase currencies to enable customers to 'tip' the developer").
/// Each can be bought any number of times and unlocks nothing.
///
/// The products must exist in App Store Connect with these IDs. To try them
/// in the simulator from Xcode, choose Product > Scheme > Edit Scheme > Run >
/// Options > StoreKit Configuration, and pick `StoreKit/Tips.storekit` at
/// the repo root.
@MainActor @Observable
final class TipJar {
    static let shared = TipJar()

    static let productIDs = [
        "com.swiftuiforhumans.app.tip.small",
        "com.swiftuiforhumans.app.tip.medium",
        "com.swiftuiforhumans.app.tip.large",
    ]

    /// Cheapest first. Empty until loaded, and stays empty when the store
    /// has no products (then nothing offers tips).
    private(set) var tips: [Tip] = []
    private var didLoad = false
    private var updates: Task<Void, Never>?

    private init() {}

    func load() async {
        guard !didLoad else { return }
        didLoad = true
        startListening()
        if LaunchOptions.isSet("-sampleTips") {
            tips = Tip.samples
            return
        }
        let products = (try? await Product.products(for: Self.productIDs)) ?? []
        tips = products.sorted { $0.price < $1.price }.map(Tip.init)
    }

    /// Finishes purchases that complete outside the app, like Ask to Buy.
    private func startListening() {
        updates = Task {
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                    Engagement.shared.recordTip()
                }
            }
        }
    }

    /// Returns `true` once the tip went through.
    func buy(_ tip: Tip, with purchase: PurchaseAction) async -> Bool {
        guard let product = tip.product else {
            // A sample tip from `-sampleTips`: pretend it worked.
            Engagement.shared.recordTip()
            return true
        }
        guard let result = try? await purchase(product) else { return false }
        switch result {
        case .success(.verified(let transaction)):
            await transaction.finish()
            Engagement.shared.recordTip()
            return true
        default:
            // Cancelled, pending (Ask to Buy), or unverified.
            return false
        }
    }
}

/// One tip size, shown as a button with its local price.
struct Tip: Identifiable {
    let id: String
    let emoji: String
    let name: String
    let price: String
    fileprivate let product: Product?

    fileprivate init(_ product: Product) {
        id = product.id
        name = product.displayName
        price = product.displayPrice
        self.product = product
        emoji = switch product.id {
        case TipJar.productIDs[0]: "☕️"
        case TipJar.productIDs[1]: "🥐"
        default: "🍰"
        }
    }

    private init(id: String, emoji: String, name: String, price: String) {
        self.id = id
        self.emoji = emoji
        self.name = name
        self.price = price
        product = nil
    }

    /// Stand-ins for screenshots and testing without a StoreKit file.
    static let samples = [
        Tip(id: "sample.small", emoji: "☕️", name: "Coffee", price: "$2.99"),
        Tip(id: "sample.medium", emoji: "🥐", name: "Coffee and a croissant", price: "$4.99"),
        Tip(id: "sample.large", emoji: "🍰", name: "Coffee and cake", price: "$9.99"),
    ]
}

/// The tip buttons, cheapest first. Shows nothing when there are no tips.
struct TipButtons: View {
    var compact = false
    var onTipped: () -> Void = {}
    @Environment(\.purchase) private var purchase
    @State private var buying: Tip.ID?

    var body: some View {
        VStack(spacing: compact ? 8 : 10) {
            ForEach(TipJar.shared.tips) { tip in
                Button {
                    buying = tip.id
                    Task {
                        if await TipJar.shared.buy(tip, with: purchase) {
                            onTipped()
                        }
                        buying = nil
                    }
                } label: {
                    HStack(spacing: 10) {
                        Text(tip.emoji)
                        Text(tip.name)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 8)
                        if buying == tip.id {
                            ProgressView()
                        } else {
                            Text(tip.price)
                                .fontWeight(.semibold)
                                .foregroundStyle(.tint)
                                .monospacedDigit()
                        }
                    }
                    .padding(.horizontal, compact ? 14 : 0)
                    .padding(.vertical, compact ? 10 : 2)
                    .frame(maxWidth: .infinity)
                    .contentShape(.rect)
                    .background {
                        if compact {
                            RoundedRectangle(cornerRadius: 14).fill(.fill.tertiary)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(buying != nil)
                .accessibilityLabel("\(tip.name), \(tip.price)")
            }
        }
        .task { await TipJar.shared.load() }
    }
}
