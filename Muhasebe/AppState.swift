import Foundation
import Combine
import SwiftUI

class AppState: ObservableObject {

    @Published var cashPosition: Double = 12450890.50
    @Published var ytdRevenue: Double = 4850320.00
    @Published var monthlyBurn: Double = 185000.00
    @Published var netMargin: Double = 24.8

    @Published var transactions: [Transaction] = []
    @Published var documents: [VaultDocument] = []

    @Published var searchQuery: String = ""
    @Published var selectedCategoryFilter: String = "All"
    @Published var selectedStatusFilter: String = "All"

    @Published var isUploadingDocument: Bool = false
    @Published var uploadProgress: Double = 0.0

    @Published var isBiometricallyLocked: Bool = true
    @Published var successHapticTrigger: Bool = false
    @Published var alertHapticTrigger: Bool = false

    init() {
        loadMockData()
    }

    func generateLedgerCSV() -> String {
        var csvString = "Vendor,Category,Amount,Date,Status,Type\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for tx in filteredTransactions {
            let formattedDate = formatter.string(from: tx.date)
            let row = "\"\(tx.vendor)\",\"\(tx.category)\",\(tx.amount),\(formattedDate),\(tx.status),\(tx.type.rawValue)\n"
            csvString.append(contentsOf: row)
        }
        return csvString
    }

    var kpis: [KPIMetric] {
        [
            KPIMetric(title: "Cash Position", value: formatCurrency(cashPosition), change: 8.2, isPositive: true, iconName: "briefcase.fill"),
            KPIMetric(title: "YTD Revenue", value: formatCurrency(ytdRevenue), change: 14.5, isPositive: true, iconName: "chart.line.uptrend.xyaxis"),
            KPIMetric(title: "Monthly Burn", value: formatCurrency(monthlyBurn), change: -2.1, isPositive: true, iconName: "flame.fill"),
            KPIMetric(title: "Net Margin", value: "\(netMargin)%", change: 3.4, isPositive: true, iconName: "percent")
        ]
    }

    var filteredTransactions: [Transaction] {
        transactions.filter { tx in
            let matchesSearch = searchQuery.isEmpty ||
                                tx.vendor.localizedCaseInsensitiveContains(searchQuery) ||
                                tx.category.localizedCaseInsensitiveContains(searchQuery)

            let matchesCategory = selectedCategoryFilter == "All" || tx.category == selectedCategoryFilter
            let matchesStatus = selectedStatusFilter == "All" || tx.status == selectedStatusFilter

            return matchesSearch && matchesCategory && matchesStatus
        }
    }

    var pendingTransactions: [Transaction] {
        transactions.filter { $0.status.lowercased() == "pending" }
    }

    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    func approveTransaction(_ id: UUID) {
        if let index = transactions.firstIndex(where: { $0.id == id }) {
            withAnimation(Theme.fluidSpring) {
                transactions[index].status = "Approved"

                let amount = transactions[index].amount
                if transactions[index].type == .income {
                    cashPosition += amount
                    ytdRevenue += amount
                } else {
                    cashPosition -= amount
                }

                netMargin = Double(round((netMargin + 0.1) * 10) / 10)

                successHapticTrigger.toggle()
            }
        }
    }

    func voidTransaction(_ id: UUID) {
        if let index = transactions.firstIndex(where: { $0.id == id }) {
            withAnimation(Theme.fluidSpring) {
                transactions[index].status = "Void"

                alertHapticTrigger.toggle()
            }
        }
    }

    func startSimulatedUpload(title: String, category: String) {
        guard !isUploadingDocument else { return }

        isUploadingDocument = true
        uploadProgress = 0.0

        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
            if self.uploadProgress < 1.0 {
                self.uploadProgress += 0.1
            } else {
                timer.invalidate()
                withAnimation(Theme.fluidSpring) {
                    let newDoc = VaultDocument(
                        id: UUID(),
                        title: title,
                        category: category,
                        size: "\(Int.random(in: 120...980)) KB",
                        uploadDate: Date()
                    )
                    self.documents.insert(newDoc, at: 0)
                    self.isUploadingDocument = false
                    self.uploadProgress = 0.0

                    self.successHapticTrigger.toggle()
                }
            }
        }
    }

    private func loadMockData() {

        let calendar = Calendar.current
        let today = Date()

        transactions = [
            Transaction(id: UUID(), vendor: "Amazon Web Services", category: "SaaS", amount: 4890.20, date: calendar.date(byAdding: .day, value: -1, to: today)!, status: "Pending", type: .expense),
            Transaction(id: UUID(), vendor: "Stripe Payout", category: "Revenue", amount: 45200.00, date: calendar.date(byAdding: .day, value: -2, to: today)!, status: "Approved", type: .income),
            Transaction(id: UUID(), vendor: "Google Workspace", category: "SaaS", amount: 840.00, date: calendar.date(byAdding: .day, value: -3, to: today)!, status: "Approved", type: .expense),
            Transaction(id: UUID(), vendor: "WeWork New York", category: "Operations", amount: 3500.00, date: calendar.date(byAdding: .day, value: -5, to: today)!, status: "Pending", type: .expense),
            Transaction(id: UUID(), vendor: "OpenAI API", category: "SaaS", amount: 1250.60, date: calendar.date(byAdding: .day, value: -6, to: today)!, status: "Approved", type: .expense),
            Transaction(id: UUID(), vendor: "Salesforce CRM", category: "Marketing", amount: 8900.00, date: calendar.date(byAdding: .day, value: -8, to: today)!, status: "Pending", type: .expense),
            Transaction(id: UUID(), vendor: "Mailchimp Newsletter", category: "Marketing", amount: 320.00, date: calendar.date(byAdding: .day, value: -10, to: today)!, status: "Approved", type: .expense),
            Transaction(id: UUID(), vendor: "Deloitte consulting", category: "Operations", amount: 15400.00, date: calendar.date(byAdding: .day, value: -12, to: today)!, status: "Void", type: .expense),
            Transaction(id: UUID(), vendor: "Client retainer - Acme", category: "Revenue", amount: 12500.00, date: calendar.date(byAdding: .day, value: -15, to: today)!, status: "Approved", type: .income)
        ]

        documents = [
            VaultDocument(id: UUID(), title: "AWS_Invoice_May2026.pdf", category: "Receipts", size: "432 KB", uploadDate: calendar.date(byAdding: .day, value: -1, to: today)!),
            VaultDocument(id: UUID(), title: "WeWork_OfficeRent_Lease.pdf", category: "Invoices", size: "2.4 MB", uploadDate: calendar.date(byAdding: .day, value: -5, to: today)!),
            VaultDocument(id: UUID(), title: "Salesforce_SalesAgreement.pdf", category: "Invoices", size: "1.1 MB", uploadDate: calendar.date(byAdding: .day, value: -8, to: today)!),
            VaultDocument(id: UUID(), title: "Deloitte_Advisory_Contract.pdf", category: "Tax Audits", size: "4.8 MB", uploadDate: calendar.date(byAdding: .day, value: -12, to: today)!)
        ]
    }
}
