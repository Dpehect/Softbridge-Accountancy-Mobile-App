import Foundation

struct KPIMetric: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: String
    let change: Double
    let isPositive: Bool
    let iconName: String
}

enum TransactionType: String, Codable {
    case income
    case expense
}

struct Transaction: Identifiable, Hashable {
    let id: UUID
    var vendor: String
    var category: String
    var amount: Double
    var date: Date
    var status: String
    var type: TransactionType

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct ChartDataPoint: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let value: Double
    var secondaryValue: Double? = nil
}

struct VaultDocument: Identifiable, Hashable {
    let id: UUID
    var title: String
    var category: String
    var size: String
    var uploadDate: Date

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: uploadDate)
    }
}
