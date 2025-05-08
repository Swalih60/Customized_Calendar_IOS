import Foundation
import Alamofire

class PriceViewModel: ObservableObject {
    @Published var priceMap: [String: Double] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchPrices(origin: String, destination: String, roundTrip: Bool) {
        let url = "https://staging.plane.lascade.com/api/price/"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        // Generate a list of future dates (e.g., next 60 days)
        let today = Date()
        var dates: [String] = []
        for i in 0..<60 {
            if let futureDate = Calendar.current.date(byAdding: .day, value: i, to: today) {
                dates.append(dateFormatter.string(from: futureDate))
            }
        }

        isLoading = true
        errorMessage = nil
        priceMap = [:]

        let dispatchGroup = DispatchGroup()
        for date in dates {
            dispatchGroup.enter()
            let parameters: [String: String] = [
                "currency": "INR",
                "country": "IN"
            ]
            let body: [String: Any] = [
                "origin": origin,
                "destination": destination,
                "departure": date,
                "round_trip": roundTrip
            ]

            AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding(destination: .queryString), headers: ["Content-Type": "application/json"])
                .validate()
                .responseDecodable(of: PriceResponse.self) { response in
                    if case .success(let priceData) = response.result, let result = priceData.results.first {
                        DispatchQueue.main.async {
                            self.priceMap[date] = Double(result.price)
                        }
                    }
                    dispatchGroup.leave()
                }
        }

        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
        }
    }
}
