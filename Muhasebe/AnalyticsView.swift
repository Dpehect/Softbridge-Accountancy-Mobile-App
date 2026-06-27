import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var state: AppState

    @State private var selectedDonutIndex: Int? = nil
    let expenseData = [
        ChartDataPoint(label: "SaaS", value: 6980.80),
        ChartDataPoint(label: "Marketing", value: 9220.00),
        ChartDataPoint(label: "Operations", value: 18900.00),
        ChartDataPoint(label: "Payroll", value: 45000.00)
    ]

    let cashFlowData = [
        ChartDataPoint(label: "Jan", value: 180000, secondaryValue: 120000),
        ChartDataPoint(label: "Feb", value: 195000, secondaryValue: 130000),
        ChartDataPoint(label: "Mar", value: 210000, secondaryValue: 155000),
        ChartDataPoint(label: "Apr", value: 245000, secondaryValue: 145000),
        ChartDataPoint(label: "May", value: 220000, secondaryValue: 165000),
        ChartDataPoint(label: "Jun", value: 285000, secondaryValue: 185000)
    ]

    @State private var dragLocationX: CGFloat = -1
    @State private var isDragging: Bool = false
    @State private var selectedPointIndex: Int = 5

    let budgetItems = [
        (category: "Operations", spent: 18900.00, budget: 25000.00),
        (category: "SaaS", spent: 6980.80, budget: 8000.00),
        (category: "Marketing", spent: 9220.00, budget: 10000.00),
        (category: "Travel", spent: 1200.00, budget: 5000.00)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        VStack(alignment: .leading, spacing: 4) {
                            Text("INSIGHT ENGINE")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.primary)
                                .tracking(1.5)

                            Text("Analytics")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(Color.black.opacity(0.85))
                        }
                        .padding(.horizontal, 16)

                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("MONTHLY CASH FLOW")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.secondaryText)
                                    .tracking(1.5)
                                Spacer()

                                HStack(spacing: 12) {
                                    HStack(spacing: 4) {
                                        Circle().fill(Theme.primary).frame(width: 8, height: 8)
                                        Text("Inflow").font(.system(size: 11, design: .rounded)).foregroundColor(Theme.secondaryText)
                                    }
                                    HStack(spacing: 4) {
                                        Circle().fill(Theme.accent).frame(width: 8, height: 8)
                                        Text("Outflow").font(.system(size: 11, design: .rounded)).foregroundColor(Theme.secondaryText)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)

                            InteractiveLineChartCard(
                                data: cashFlowData,
                                dragLocationX: $dragLocationX,
                                isDragging: $isDragging,
                                selectedPointIndex: $selectedPointIndex,
                                state: state
                            )
                            .padding(.horizontal, 16)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            Text("EXPENSE DISTRIBUTION")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.secondaryText)
                                .tracking(1.5)
                                .padding(.horizontal, 16)

                            PremiumCard(padding: 20) {
                                VStack(spacing: 24) {
                                    DonutChartView(
                                        data: expenseData,
                                        selectedIndex: $selectedDonutIndex,
                                        state: state
                                    )
                                    .frame(height: 180)

                                    VStack(spacing: 10) {
                                        ForEach(expenseData.indices, id: \.self) { index in
                                            let item = expenseData[index]
                                            let gradients = [Theme.saasGradient, Theme.marketingGradient, Theme.opsGradient, Theme.revenueGradient]
                                            let activeGradient = gradients[index % gradients.count]
                                            let isSelected = selectedDonutIndex == index

                                            HStack {
                                                Circle()
                                                    .fill(activeGradient)
                                                    .frame(width: 10, height: 10)

                                                Text(item.label)
                                                    .font(.system(size: 14, weight: isSelected ? .bold : .medium, design: .rounded))
                                                    .foregroundColor(isSelected ? Theme.primary : Color.black.opacity(0.8))

                                                Spacer()

                                                Text(state.formatCurrency(item.value))
                                                    .font(.system(size: 14, weight: isSelected ? .bold : .semibold, design: .monospaced))
                                                    .foregroundColor(isSelected ? Theme.primary : Color.black.opacity(0.8))
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(isSelected ? Theme.primary.opacity(0.06) : Color.clear)
                                            .cornerRadius(10)
                                            .onTapGesture {
                                                withAnimation(Theme.fluidSpring) {
                                                    if selectedDonutIndex == index {
                                                        selectedDonutIndex = nil
                                                    } else {
                                                        selectedDonutIndex = index
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            Text("CATEGORY BUDGETING")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.secondaryText)
                                .tracking(1.5)
                                .padding(.horizontal, 16)

                            PremiumCard(padding: 20) {
                                VStack(spacing: 16) {
                                    ForEach(budgetItems, id: \.category) { item in
                                        BudgetRow(category: item.category, spent: item.spent, budget: item.budget, state: state)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 12)
                }
            }
            .hideNavigationBar()
        }
    }
}

struct InteractiveLineChartCard: View {
    let data: [ChartDataPoint]
    @Binding var dragLocationX: CGFloat
    @Binding var isDragging: Bool
    @Binding var selectedPointIndex: Int
    let state: AppState

    var body: some View {
        PremiumCard(padding: 16) {
            VStack(alignment: .leading, spacing: 16) {

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(data[selectedPointIndex].label.uppercased() + " SUMMARY")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.secondaryText)

                        HStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("Inflow")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundColor(Theme.secondaryText)
                                Text(state.formatCurrency(data[selectedPointIndex].value))
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(Theme.primary)
                            }

                            VStack(alignment: .leading) {
                                Text("Outflow")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundColor(Theme.secondaryText)
                                Text(state.formatCurrency(data[selectedPointIndex].secondaryValue ?? 0))
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(Theme.accent)
                            }
                        }
                    }
                    Spacer()

                    if isDragging {
                        Text("Dragging")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.primary)
                            .cornerRadius(6)
                    }
                }
                .padding(.bottom, 8)

                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    let step = w / CGFloat(data.count - 1)

                    let inflowPoints = data.enumerated().map { index, pt in
                        CGPoint(x: CGFloat(index) * step, y: normalizeY(pt.value, height: h))
                    }

                    let outflowPoints = data.enumerated().map { index, pt in
                        CGPoint(x: CGFloat(index) * step, y: normalizeY(pt.secondaryValue ?? 0, height: h))
                    }

                    ZStack {

                        Path { path in
                            for i in 0...3 {
                                let y = h * CGFloat(i) / 3
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: w, y: y))
                            }
                        }
                        .stroke(Theme.border.opacity(0.6), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

                        Path { path in
                            path.move(to: CGPoint(x: 0, y: h))
                            for pt in inflowPoints {
                                path.addLine(to: pt)
                            }
                            path.addLine(to: CGPoint(x: w, y: h))
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [Theme.primary.opacity(0.12), Theme.primary.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        Path { path in
                            path.move(to: inflowPoints[0])
                            for pt in inflowPoints {
                                path.addLine(to: pt)
                            }
                        }
                        .stroke(Theme.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        .glow(color: Theme.primary, radius: 6)

                        Path { path in
                            path.move(to: outflowPoints[0])
                            for pt in outflowPoints {
                                path.addLine(to: pt)
                            }
                        }
                        .stroke(Theme.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        .glow(color: Theme.accent, radius: 6)

                        if isDragging {
                            let dragX = max(0, min(dragLocationX, w))

                            Path { path in
                                path.move(to: CGPoint(x: dragX, y: 0))
                                path.addLine(to: CGPoint(x: dragX, y: h))
                            }
                            .stroke(Theme.primary.opacity(0.4), lineWidth: 1.5)

                            let snPt = inflowPoints[selectedPointIndex]
                            let snPt2 = outflowPoints[selectedPointIndex]

                            Circle()
                                .fill(Theme.primary)
                                .frame(width: 10, height: 10)
                                .position(snPt)
                                .shadow(radius: 2)

                            Circle()
                                .fill(Theme.accent)
                                .frame(width: 10, height: 10)
                                .position(snPt2)
                                .shadow(radius: 2)
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { val in
                                isDragging = true
                                dragLocationX = val.location.x

                                let rawIndex = Int(round(dragLocationX / step))
                                selectedPointIndex = max(0, min(rawIndex, data.count - 1))
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.25)) {
                                    isDragging = false
                                }
                            }
                    )
                }
                .frame(height: 140)

                HStack {
                    ForEach(data.indices, id: \.self) { index in
                        Text(data[index].label)
                            .font(.system(size: 11, weight: selectedPointIndex == index ? .bold : .medium, design: .rounded))
                            .foregroundColor(selectedPointIndex == index ? Theme.primary : Theme.secondaryText)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private func normalizeY(_ val: Double, height: CGFloat) -> CGFloat {
        let maxVal = 300000.0
        let minVal = 100000.0
        let pct = (val - minVal) / (maxVal - minVal)

        return height * (1.0 - CGFloat(pct))
    }
}

struct DonutChartView: View {
    let data: [ChartDataPoint]
    @Binding var selectedIndex: Int?
    let state: AppState

    var totalExpense: Double {
        data.map { $0.value }.reduce(0, +)
    }

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2

            ZStack {

                ForEach(data.indices, id: \.self) { index in
                    let slice = getSlice(for: index)
                    let isSelected = selectedIndex == index

                    DonutSliceShape(
                        startAngle: slice.start,
                        endAngle: slice.end,
                        innerRadiusRatio: 0.65
                    )
                    .fill(gradientForIndex(index))
                    .scaleEffect(isSelected ? 1.06 : 1.0)
                    .animation(Theme.fluidSpring, value: isSelected)
                    .onTapGesture {
                        withAnimation(Theme.fluidSpring) {
                            if selectedIndex == index {
                                selectedIndex = nil
                            } else {
                                selectedIndex = index
                            }
                        }
                    }
                }

                Circle()
                    .fill(Color.white)
                    .frame(width: radius * 1.3, height: radius * 1.3)
                    .shadow(color: Color.black.opacity(0.04), radius: 4)

                VStack(spacing: 2) {
                    if let idx = selectedIndex {
                        Text(data[idx].label.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.secondaryText)

                        Text(state.formatCurrency(data[idx].value))
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(colorForIndex(idx))

                        Text(String(format: "%.1f%%", (data[idx].value / totalExpense) * 100))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.secondaryText)
                    } else {
                        Text("TOTAL EXPENSES")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.secondaryText)
                            .tracking(1.0)

                        Text(state.formatCurrency(totalExpense))
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.black.opacity(0.85))
                    }
                }
            }
        }
    }

    private func gradientForIndex(_ index: Int) -> LinearGradient {
        let gradients = [Theme.saasGradient, Theme.marketingGradient, Theme.opsGradient, Theme.revenueGradient]
        return gradients[index % gradients.count]
    }

    private func colorForIndex(_ index: Int) -> Color {
        let colors = [Color(hex: "4361EE"), Color(hex: "FF7F50"), Color(hex: "7209B7"), Color(hex: "2D6A4F")]
        return colors[index % colors.count]
    }

    private func getSlice(for index: Int) -> (start: Angle, end: Angle) {
        var startSum = 0.0
        for i in 0..<index {
            startSum += data[i].value
        }

        let startAngle = (startSum / totalExpense) * 360.0 - 90.0
        let endAngle = ((startSum + data[index].value) / totalExpense) * 360.0 - 90.0
        return (Angle(degrees: startAngle), Angle(degrees: endAngle))
    }
}

struct DonutSliceShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let innerRadiusRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRadiusRatio

        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )

        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: true
        )

        path.closeSubpath()
        return path
    }
}

struct BudgetRow: View {
    let category: String
    let spent: Double
    let budget: Double
    let state: AppState

    var percentSpent: Double {
        min(spent / budget, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.85))

                Spacer()

                Text("\(state.formatCurrency(spent)) spent of \(state.formatCurrency(budget))")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Theme.secondaryText)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.border.opacity(0.5))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(gradientForCategory(category))
                        .frame(width: geo.size.width * CGFloat(percentSpent), height: 12)
                        .animation(.easeOut(duration: 0.6), value: percentSpent)
                }
            }
            .frame(height: 12)
        }
    }

    private func gradientForCategory(_ category: String) -> LinearGradient {
        switch category.lowercased() {
        case "operations":
            return Theme.opsGradient
        case "saas":
            return Theme.saasGradient
        case "marketing":
            return Theme.marketingGradient
        case "revenue":
            return Theme.revenueGradient
        default:
            return Theme.primaryGradient
        }
    }
}
