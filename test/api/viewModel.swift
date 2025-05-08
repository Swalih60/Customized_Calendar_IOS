import Foundation
import Alamofire

struct FlightSearchBody: Encodable {
    let origin: String
    let destination: String
    let departure: String
    let round_trip: Bool
}

class PriceModel: ObservableObject {
    @Published var prices: [PriceResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchPrices() {
        let baseURL = "https://staging.plane.lascade.com/api/price/"
        let queryParams = [
            "currency": "INR",
            "country": "IN"
        ]

        // Construct full URL with query items
        var components = URLComponents(string: baseURL)!
        components.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let urlWithQuery = components.url else {
            print("❌ Invalid URL")
            return
        }

        // Body as JSON
        let body = FlightSearchBody(
            origin: "COK",
            destination: "DXB",
            departure: "08-05-2025",
            round_trip: true
        )

        isLoading = true
        errorMessage = nil

        AF.request(urlWithQuery, method: .post, parameters: body, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: PriceResponse.self) { response in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch response.result {
                    case .success(let priceData):
                        self.prices = priceData.results
                        print("✅ Fetched \(self.prices.count) prices")
                    case .failure(let error):
                        self.errorMessage = "❌ \(error.localizedDescription)"
                        print("❌ Alamofire Error: \(error)")
                    }
                }
            }
    }
}
