import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var state: AppState
    @State private var selectedTransaction: Transaction? = nil

    let categories = ["All", "Revenue", "SaaS", "Operations", "Marketing"]
    let statuses = ["All", "Approved", "Pending", "Void"]

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("LEDGER")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.primary)
                                    .tracking(1.5)

                                Text("Transactions")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.black.opacity(0.85))
                            }
                            Spacer()

                            HStack(spacing: 8) {

                                Text("\(state.filteredTransactions.count) records")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(Theme.primary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Theme.primary.opacity(0.08))
                                    .cornerRadius(8)

                                ShareLink(
                                    item: state.generateLedgerCSV(),
                                    preview: SharePreview("Soft_Bridge_Ledger.csv", image: Image(systemName: "doc.text"))
                                ) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Theme.primary)
                                        .padding(8)
                                        .background(Theme.primary.opacity(0.08))
                                        .cornerRadius(8)
                                }
                            }
                        }

                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Theme.secondaryText)
                                .padding(.leading, 12)

                            TextField("Search vendor, category...", text: $state.searchQuery)
                                .font(.system(size: 15))
                                .foregroundColor(Color.black.opacity(0.85))
                                .padding(.vertical, 10)
                                .padding(.trailing, 12)

                            if !state.searchQuery.isEmpty {
                                Button(action: {
                                    state.searchQuery = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Theme.secondaryText)
                                        .padding(.trailing, 10)
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.border, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    withAnimation(Theme.fluidSpring) {
                                        state.selectedCategoryFilter = category
                                    }
                                }) {
                                    Text(category)
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(state.selectedCategoryFilter == category ? .white : Theme.secondaryText)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(state.selectedCategoryFilter == category ? Theme.primary : Color.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(state.selectedCategoryFilter == category ? Color.clear : Theme.border, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }

                    HStack(spacing: 8) {
                        ForEach(statuses, id: \.self) { status in
                            Button(action: {
                                withAnimation(Theme.fluidSpring) {
                                    state.selectedStatusFilter = status
                                }
                            }) {
                                Text(status)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(state.selectedStatusFilter == status ? Theme.primary : Theme.secondaryText)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(state.selectedStatusFilter == status ? Theme.primary.opacity(0.08) : Color.clear)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(4)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    if state.filteredTransactions.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(Theme.secondaryText.opacity(0.5))

                            Text("No Transactions Found")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color.black.opacity(0.85))

                            Text("Try adjusting your filters or search terms.")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(Theme.secondaryText)
                        }
                        .padding(.horizontal, 24)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(state.filteredTransactions) { tx in
                                    TransactionRow(transaction: tx)
                                        .onTapGesture {
                                            selectedTransaction = tx
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .hideNavigationBar()
            .sheet(item: $selectedTransaction) { tx in
                TransactionDetailSheet(transaction: tx)
            }
            .sensoryFeedbackSuccess(trigger: state.successHapticTrigger)
            .sensoryFeedbackAlert(trigger: state.alertHapticTrigger)
        }
    }
}

struct TransactionRow: View {
    @EnvironmentObject var state: AppState
    let transaction: Transaction
    @State private var pressScale: CGFloat = 1.0

    var body: some View {
        PremiumCard(padding: 0) {
            HStack(spacing: 0) {

                Rectangle()
                    .fill(gradientForCategory(transaction.category))
                    .frame(width: 5)

                HStack(spacing: 12) {
                    VendorIcon(name: transaction.vendor, size: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(transaction.vendor)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Color.black.opacity(0.85))
                            .lineLimit(1)

                        HStack(spacing: 6) {
                            Text(transaction.category)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(Theme.secondaryText)

                            Circle()
                                .fill(Theme.border)
                                .frame(width: 3, height: 3)

                            Text(transaction.formattedDate)
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(Theme.secondaryText)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        let prefix = transaction.type == .income ? "+" : "-"
                        let color = transaction.type == .income ? Theme.statusApproved : Color.black.opacity(0.85)

                        Text("\(prefix)\(state.formatCurrency(transaction.amount))")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(color)

                        StatusBadge(status: transaction.status)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
            }
        }
        .scaleEffect(pressScale)
        .animation(.easeOut(duration: 0.15), value: pressScale)
    }

    private func gradientForCategory(_ category: String) -> LinearGradient {
        switch category.lowercased() {
        case "revenue":
            return Theme.revenueGradient
        case "saas":
            return Theme.saasGradient
        case "operations":
            return Theme.opsGradient
        case "marketing":
            return Theme.marketingGradient
        default:
            return Theme.primaryGradient
        }
    }
}

struct TransactionDetailSheet: View {
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    let transaction: Transaction

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 24) {

                Capsule()
                    .fill(Theme.secondaryText.opacity(0.3))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)

                VStack(spacing: 8) {
                    VendorIcon(name: transaction.vendor, size: 64)

                    Text(transaction.vendor)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.85))

                    StatusBadge(status: transaction.status)
                }

                VStack(spacing: 0) {
                    DetailRow(title: "Amount", value: state.formatCurrency(transaction.amount), isMonospaced: true)
                    Divider().background(Theme.border)
                    DetailRow(title: "Category", value: transaction.category)
                    Divider().background(Theme.border)
                    DetailRow(title: "Date", value: transaction.formattedDate)
                    Divider().background(Theme.border)
                    DetailRow(title: "Ref ID", value: transaction.id.uuidString.prefix(12).uppercased(), isMonospaced: true)
                }
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 16) {
                    Text("AUDIT TIMELINE")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.secondaryText)
                        .tracking(1.5)
                        .padding(.horizontal, 4)

                    VStack(alignment: .leading, spacing: 16) {
                        TimelineNode(time: "10:30 AM", title: "Transaction Created", desc: "Logged automatically via Stripe Integration API", isCompleted: true)
                        TimelineNode(time: "10:32 AM", title: "OCR Matching completed", desc: "Matched with uploaded PDF Invoice #1920", isCompleted: true)

                        if transaction.status == "Approved" {
                            TimelineNode(time: "11:45 AM", title: "Controller Approved", desc: "Approved by Admin User (SE) via mobile app", isCompleted: true, isLast: true)
                        } else if transaction.status == "Pending" {
                            TimelineNode(time: "Pending", title: "Needs Verification", desc: "Awaiting CFO / Controller authorization", isCompleted: false, isLast: true)
                        } else {
                            TimelineNode(time: "11:45 AM", title: "Transaction Voided", desc: "Marked void by Admin User (SE)", isCompleted: false, isAlert: true, isLast: true)
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)

                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.primary)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    var isMonospaced: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Theme.secondaryText)
            Spacer()
            Text(value)
                .font(isMonospaced ? .system(size: 14, weight: .semibold, design: .monospaced) : .system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color.black.opacity(0.85))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct TimelineNode: View {
    let time: String
    let title: String
    let desc: String
    var isCompleted: Bool
    var isAlert: Bool = false
    var isLast: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack {
                Circle()
                    .fill(isAlert ? Theme.accent : (isCompleted ? Theme.statusApproved : Theme.secondaryText.opacity(0.3)))
                    .frame(width: 10, height: 10)

                if !isLast {
                    Rectangle()
                        .fill(Theme.border)
                        .frame(width: 2, height: 35)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.85))
                    Spacer()
                    Text(time)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Theme.secondaryText)
                }
                Text(desc)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Theme.secondaryText)
            }
        }
    }
}
