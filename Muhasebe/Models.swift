//
//  Models.swift
//  Muhasebe
//
//  Created by Soft Bridge Solutions UI/UX on 27.06.2026.
//

import Foundation

/// Top-level KPI model for the dashboard widgets.
struct KPIMetric: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: String
    let change: Double       // e.g. 12.4 for +12.4%
    let isPositive: Bool     // true for growth/positive trend, false for negative/burn
    let iconName: String     // SF Symbol name
}

/// Transaction type (Income vs Expense).
enum TransactionType: String, Codable {
    case income
    case expense
}

/// A transaction representation in the Ledger list.
struct Transaction: Identifiable, Hashable {
    let id: UUID
    var vendor: String
    var category: String
    var amount: Double
    var date: Date
    var status: String       // "Approved", "Pending", "Void"
    var type: TransactionType
    
    // Formatting date to clean string
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

/// Analytics data structure for line, bar, and donut charts.
struct ChartDataPoint: Identifiable, Hashable {
    let id = UUID()
    let label: String        // Month name, Category name, etc.
    let value: Double
    var secondaryValue: Double? = nil // Optional second series (e.g. Budget vs Actual)
}

/// Document representation for the Vault screen.
struct VaultDocument: Identifiable, Hashable {
    let id: UUID
    var title: String
    var category: String     // "Receipts", "Invoices", "Tax Audits"
    var size: String
    var uploadDate: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: uploadDate)
    }
}
