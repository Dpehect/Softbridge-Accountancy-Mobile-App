import SwiftUI

struct PremiumCard<Content: View>: View {
    var padding: CGFloat = 16
    let content: Content

    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .premiumCard()
    }
}

struct StatusBadge: View {
    let status: String

    var body: some View {
        let (fgColor, bgColor) = colorsForStatus(status)

        Text(status.uppercased())
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(fgColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(bgColor)
            .cornerRadius(10)
    }

    private func colorsForStatus(_ status: String) -> (Color, Color) {
        switch status.lowercased() {
        case "approved":
            return (Theme.statusApproved, Theme.statusApprovedBg)
        case "pending":
            return (Theme.statusPending, Theme.statusPendingBg)
        case "void":
            return (Theme.statusVoid, Theme.statusVoidBg)
        default:
            return (Theme.secondaryText, Theme.background)
        }
    }
}

struct VendorIcon: View {
    let name: String
    var size: CGFloat = 40

    var initials: String {
        let words = name.components(separatedBy: " ")
        let firstChars = words.compactMap { $0.first }
        if firstChars.isEmpty { return "SB" }
        return String(firstChars.prefix(2)).uppercased()
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Theme.primary.opacity(0.15), Theme.primary.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(initials)
                .font(.system(size: size * 0.4, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.primary)
        }
        .frame(width: size, height: size)
        .overlay(
            Circle()
                .stroke(Theme.primary.opacity(0.1), lineWidth: 1)
        )
    }
}
