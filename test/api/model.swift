import Foundation

struct PriceResponse: Codable {
    let priceStats: PriceStats
    let results: [PriceResult]

    enum CodingKeys: String, CodingKey {
        case priceStats = "price_stats"
        case results
    }
}

struct PriceStats: Codable {
    let mean: Double
    let stdDev: Double
    let lowerThreshold: Double
    let upperThreshold: Double

    enum CodingKeys: String, CodingKey {
        case mean
        case stdDev = "std_dev"
        case lowerThreshold = "lower_threshold"
        case upperThreshold = "upper_threshold"
    }
}

struct PriceResult: Codable, Identifiable {
    var id: Int { date }

    let date: Int
    let price: Int
    let currency: String
    let priceCategory: String

    enum CodingKeys: String, CodingKey {
        case date, price, currency
        case priceCategory = "price_category"
    }
}
