import SwiftUI

struct apiDisplay: View {
    @StateObject var viewModel = PriceModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    List(viewModel.prices) { price in
                        VStack(alignment: .leading) {
                            Text("₹\(price.price)")
                                .font(.headline)
                            Text("Date: \(formatDate(from: price.date))")
                            Text("Category: \(price.priceCategory)")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Flight Prices")
            .onAppear {
                viewModel.fetchPrices()
            }
        }
    }

    private func formatDate(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
#Preview {
    apiDisplay()
}
